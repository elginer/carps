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

require "carps/util/warn"
require "carps/util/process"
require "carps/util/files"

require "drb"

module CARPS

   # The mailbox's responsibility is in sending messages and securely and robustly receiving them
   #
   # It has knowledge is of the public keys of the Mailer s of the remote peers
   class Mailbox

      include DRbUndumped

      # Create the mailbox from a simple, synchronous mail sender and receiver.
      #
      # The third parameter is a MessageParser.
      #
      # The fourth parameter is a SessionManager.
      def initialize sender, receiver, parser, manager
         @manager = manager 
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
         # Load mails from the last session
         load_old_mails
         # Receive mail
         receive_forever
      end

      # Shutdown the mailbox
      def shutdown
         @child.kill
      end

      # Add a new peer
      def add_peer peer
         @peers[peer.addr] = peer
      end

      # Is this already a peer?
      def peer? peer
         @peers.member? peer
      end

      # Send a message
      def send to, message
         @ssemaphore.synchronize do
            message = @manager.tag message
            @sender.send to, message
         end
      end

      # Securely read a message.  Block until one occurs.
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

      # Check for a new message.  Don't block
      def check type, must_be_from=nil
         search type, must_be_from
      end

      # Insecurely read a message.  Block until one comes.
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

      # Check for new messages insecurely.  Don't block.
      def insecure_check type, must_be_from=nil
         insecure_search type, must_be_from
      end

      private

      # See if there is an appropriate message in the mail box
      def search type, must_be_from
         @rsemaphore.synchronize do
            @mail.each_index do |index|
               mail = @mail[index]
               from = mail.from
               if secure from
                  unless @peers[from].verify mail
                     remove_mail index
                     next
                  end
               end
               pass = appropriate?(mail, type, must_be_from)
               if pass
                  remove_mail index
                  return mail
               end
            end
            nil
         end
      end

      # Was the mail message appropriate?
      def appropriate? mail, type, must_be_from
         pass = mail.class == type
         if must_be_from
            pass = pass and mail.from == must_be_from
         end
         pass and @manager.belong? mail
      end

      # Remove a mail message
      def remove_mail index
         @mail[index].delete
         @mail.delete_at index
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
               pass = appropriate?(mail, type, must_be_from)
               if pass
                  remove_mail index
                  return mail
               end
            end
            nil
         end
      end

      # Receive new mail
      def receive_forever
         @child = Thread.fork do
            loop do
               receive_new
               sleep 1
            end
         end
      end

      # Read new mail messages into the mail box
      def receive_new
         mail = @receiver.read
         mail.each do |blob|
            decode_mail blob
         end
      end

      # Read a new mail message from a blob of text
      def decode_mail blob, persistence = {:save_mail => true}
         input = blob
         # Find the message's session
         session = nil
         begin
            session, blob = find K.session, blob
         rescue Expected
            UI::warn "Mail message did not contain session.", blob
            return
         end
         who = nil

         begin
            # Find who sent the message
            who, blob = find K.addr, blob
         rescue Expected
            UI::warn "Mail message did not contain sender.", blob
            return
         end

         # Get the security information from the mail
         delayed_crypt, blob = security_info blob

         # Parse a message
         msg = @parser.parse blob

         if msg
            msg.session = session
            msg.crypt = delayed_crypt
            msg.from = who 
            puts "Mail from #{who}: #{msg.class.to_s}"
            # Save the text we parsed the message from.
            if persistence[:save_mail] 
               msg.save input
            end
            path = persistence[:path]
            if path
               msg.path = path
            end
            @rsemaphore.synchronize do
               @mail.push msg
            end
         else
            UI::warn "Failed to parse message from #{who}"
         end
      end

      # Load mails from the last session
      def load_old_mails
         old_mails = files $CONFIG + "/.mail"
         old_mails.each do |fn|
            blob = nil
            begin
               blob = File.read fn
            rescue StandardError => e
               UI::put_error "Could not read old message: #{e}"
            end
            if blob
               blob.force_encoding "ASCII-8BIT"
               decode_mail blob, {:save_mail => false, :path => fn}
            end
         end
      end

   end

end
