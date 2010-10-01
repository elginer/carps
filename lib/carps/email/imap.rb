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


require "carps/protocol/message"
require "carps/util/warn"
require "carps/email/string"

require "net/imap"

module CARPS

   # Administer IMAP connections
   class IMAP

      # Initialize with a hash of IMAP settings and password
      #
      # Uh, poorly documented.  See source.
      def initialize settings, password
         @port = settings["port"]
         @server = settings["server"]
         @tls = settings["tls"]
         @username = settings["user"]
         @password = password
      end

      # Are the settings okay?
      def ok?
         good = false
         begin
            attempt_connection
            @imap.logout
            good = true
         rescue StandardError => e
            put_error e.to_s
         end
         good
      end

      # Attempt a connection
      def attempt_connection
         puts "Making IMAP connection for " + @username
         puts "Server: #{@server}, Port: #{@port}"
         if not @tls or @password.empty?
            warn "IMAP connection is insecure."
         end
         @imap = Net::IMAP.new @server, @port, @tls, nil, false
         @imap.login @username, @password
         @imap
      end

      # Connect to imap server
      def connect
         until false
            begin
               attempt_connection
               return
            rescue
               warn "Could not connect to IMAP server", "Attempting to reconnect in 10 seconds."
               sleep 10
            end 
         end
      end

      # Return the a list of email message bodies
      #
      # If the inbox is empty, wait delay seconds before polling it again
      def read 
         # A reader
         reader = lambda do
            mails = []
            # Block 'till we get one
            while mails.empty?
               @imap.select("inbox")
               messages = @imap.search(["UNSEEN"])
               if messages.empty?
                  sleep delay
               else
                  mails = @imap.fetch messages, "BODY[TEXT]"
                  mails = mails.map do |mail|
                     from_mail mail.attr["BODY[TEXT]"]
                  end
               end
            end
            mails
         end
         mails = []
         until 
            begin
               mails = reader.call
            rescue
               warn "Could not receive IMAP messages", "Attempting to reconnect" 
               connect
            end
         end
         mails
      end

   end

end
