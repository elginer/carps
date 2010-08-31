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
      receive_forever
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

   # Securely read a message 
   def read type, must_be_from=nil
      msg = nil
      until msg
         msg = search type, must_be_from
         sleep 1
      end
      # Ding!
      puts "\a"
      return msg
   end

   # Insecurely read a message
   def insecure_read type, must_be_from=nil
      msg = nil
      until msg
         msg = insecure_search type, must_be_from
         sleep 1
      end
      # Ding!
      puts "\a"
      return msg
   end

   # See if there is an appropriate message in the mail box
   def search type, must_be_from
      @rsemaphore.synchronize do
         @mail.each_index do |index|
            mail = @mail[index]
            from = mail.from
            pass = false 
            if secure from
               unless @peers[from].verify mail
                  @mail.delete_at index
                  next
               end
            end
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
   end

   # Communication with someone is secure if there is a peer for them
   def secure addr
      @peers.member? addr
   end

   # Insecurely see if there is an appropriate message in the mail box
   def insecure_search type, must_be_from
      @rsemaphore.synchronize do
         @mail.each_index do |index|
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
   end

   # Receive new mail
   def receive_forever
      Thread.fork do
         loop do
            receive_new
         end
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

         # Get the security information from the mail
         delayed_crypt, blob = security_info blob

         # Parse a message
         msg = @parser.parse who, blob, delayed_crypt
         unless msg
            warn "Failed to parse message from #{who}", blob
         end 
         puts "Mail from #{who}: #{msg.class.to_s}"
         @rsemaphore.synchronize do
            @mail.push msg
         end
      end
   end

end
