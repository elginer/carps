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


require "protocol/message"
require "util/warn"

require "net/imap"

require "email/string"

# Administer IMAP connections
class IMAP

   # Connect to the server with username and password
   def initialize settings, username, password
      @port = settings["port"]
      @server = settings["server"]
      @tls = settings["tls"]
      @username = username
      @password = password
      connect

   end

   # Connect to imap server
   def connect
      until false
         puts "Making IMAP connection for " + @username
         puts "Server: #{@server}, Port: #{@port}"
         begin
            @imap = Net::IMAP.new @server, @port, @tls, nil, false
            @imap.login @username, @password
            return
         rescue
            warn "Could not connect to IMAP server", "Attempting to reconnect in 10 seconds."
            sleep 10
         end 
      end
   end

   def delay
      10
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
