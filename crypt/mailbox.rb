# Copyright 2010 John Morrice
 
# This file is part of CARPS.

# CARPS is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# CARPS is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with CARPS.  If not, see <http://www.gnu.org/licenses/>.

# This mailbox receives all messages that come in

require "util/warn"
require "util/process"

require "drb"

class Mailbox

   include DRbUndumped

   # Create the mailbox from a simple, synchronous mail client
   def initialize sender, receiver, parser 
      @receiver = receiver
      @parser = parser
      @sender = sender
      @mail = []
      @peers = {}
      @secure = false
      # Semaphore to make sure only one thread can send mail at any one time
      @ssemaphore = Mutex.new
      # Semaphore to make sure only one thread can receive mail at any one time 
      @rsemaphore = Mutex.new
      # Receive mail
      Thread.fork do
         receive_forever
      end
   end

   # The mail is now secure
   def secure
      @secure = true
   end

   # Add a new peer
   def add_peer addr, peer
      @peers[addr] = peer
   end

   # Is this already a peer?
   def peer? peer
      @peers.member? peer
   end

   # Send a message
   def send to, message
      @ssemaphore.synchronize do
         @sender.send to, message
      end
   end

   # A container
   class Container
     
      include DRbUndumped
 
      def empty?
         @contents == nil
      end
      
      def push a
         @contents = a
      end

      def contents
         @contents
      end
   end

   # Read a message 
   def read type, must_be_from
      msgc = Container.new
      puts "Attempting to read #{type.to_s}"
      mailc = Container.new 
      child = spawn_mail_reader type, must_be_from, [self, mailc]
      puts "Waiting for #{type} from #{child} process"
      Process.wait child
      puts "Received message..."
      # Ding!
      puts "\a"
      msgc.contents
   end

   # See if there is an appropriate message in the mail box
   def search type, must_be_from
      puts "Mail size: #{@mail.size}"
      sleep 1
      @mail.each_index do |index|
         puts "Attempting to find: #{type.to_s}"
         puts "This mail: #{@mail[index].class.to_s}"
         puts "Number of mails: #{@mail.size}"
         mail = @mail[index]
         pass = true

         if type
            pass = mail.class == type
         end
         if must_be_from
            pass = pass and mail.from == must_be_from
         end
         if pass
            @mail.delete_at index
            return mail
         end
      end
      nil
   end

   # Check if a blob is valid
   def valid who, blob
      # If we're in a secure state...
      if @secure
         unless(peer = @peers[who])
           warn "Unregistered peer #{who}", blob
           return nil
         end
         # Strip the last end marker and any text after it
         blob = clean_end blob
         # The peer will verify the signature at the start of the text and pass on the rest
         if(text = peer.verify blob)
            return text
         else
            return nil
         end
      else
         return blob
      end
   end

   # Receive new mail
   def receive_forever
      loop do
         receive_new
      end
   end

   # Read new mail messages into the mail box
   def receive_new 
      mail = @receiver.read

      mail.each do |blob|
         who = nil
         begin
            # Find who sent the message
            who, blob = find K.addr, blob
         rescue Expected
            warn "Mail message did not contain sender.", blob 
            next
         end

         unless(blob = valid(who, blob))
            next
         end

         # Parse a message
         msg = @parser.parse who, blob
         unless msg
            warn "Failed to parse message from #{who}", blob
         end 
         puts "Mail from #{who}: #{msg.class.to_s}"
         @rsemaphore.synchronize do
            @mail.push msg
         end
      end
   end

   # Clean the end of an email
   #
   # Strip the last end marker and any text after it 
   def clean_end blob
      rb = blob.reverse
      before, after = rb.split K.end.reverse, 2
      if after
         return after.reverse
      end
      nil
   end

end

def spawn_mail_reader type, must_be_from, maild
   mail = maild[0]
   mailc = maild[1]
   ashare mailc, lambda {|uri|
         mailcontainer = DRbObject.new nil, uri
         msgc = mailcontainer.msg
         mail = mailcontainer.mail
         puts "Waiting for msgc to be full"
         while msgc.empty?
            msgc.push mail.search type, must_be_from
         end
         puts "Ace, got the message"
   }
end
