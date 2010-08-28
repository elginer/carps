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

class Mailbox

   # Create the mailbox from a simple, synchronous mail client
   def initialize sender, receiver, parser 
      @receiver = receiver
      @parser = parser
      @sender = sender
      @mail = []
      @peers = {}
      @secure = false
      @semaphore = Mutex.new
   end

   # The mail is now secure
   def secure
      @secure = true
   end

   # Add a new peer
   def add_peer addr, peer
      @peers[addr] = peer
   end

   # Send a message
   def send to, message
      @sender.send to, message
   end

   # Read a message 
   def read type, must_be_from
      msg = nil
      until msg
         puts "reading..."
         if(msg = search(type, must_be_from))
         else
            receive_new
         end
      end
      # Ding!
      puts "\a"
      return msg
   end

   # See if there is an appropriate message in the mail box
   def search type, must_be_from
      puts "Searching for #{type} from #{must_be_from}"
      @semaphore.synchronize do
         @mail.each_index do |index|
            mail = @mail[index]
            puts "Mail: #{mail.class} from #{mail.from}"
            pass = true
            if type
               pass = mail.class == type
            end
            puts "Type correct: #{pass}"
            if must_be_from
               pass = pass and mail.from == must_be_from
            end
            puts "Sender correct: #{pass}"
            if pass
               @mail.delete_at index
               return mail
            end
         end
      end
      puts "Searching failed"
      nil
   end

   # Check if a blob is valid
   def valid who, blob
      # If we're in a secure state...
      if @secure
         unless(peer = @peers[who])
           log "Unregistered peer #{who}", blob
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

   # Read new mail messages into the mail box
   def receive_new 
      mail = @receiver.read

      mail.each do |blob|
         who = nil
         begin
            # Find who sent the message
            who, blob = find K.addr, blob 
            puts "Received mail from #{who}."
         rescue Expected
            log "Mail message did not contain sender.", blob 
            next
         end

         unless(blob = valid(who, blob))
            next
         end

         puts "Parsing:"
         puts blob

         # Parse a message
         msg = @parser.parse who, blob
         unless msg
            log "Failed to parse message from #{who}", blob
         end
         puts "Mail from #{who} was a #{msg.class.to_s}"
         @semaphore.synchronize do
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
