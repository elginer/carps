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


require "protocol/message.rb"
require "util/log.rb"

require "net/imap.rb"


# Administer IMAP connections
class IMAP

   # Connect to the server with username and password
   def initialize server, username, password
      @server = server
      @username = username
      @password = password
      connect

   end

   # Connect to imap server
   def connect
      until false 
         begin
            puts "Making IMAP connection for " + @username
            @imap = Net::IMAP.new(@server, 993, true)
            @imap.login(@username, @password)
            return
         rescue
            log "Could not connect to IMAP server", "Attempting to reconnect."
         end 
      end
   end

   # Return the next email message
   #
   # If the inbox is empty, wait delay seconds before polling it again
   def read 
      # A reader
      reader = lambda do
         # Block 'till we get one
         while true
            @imap.select("inbox")
            messages = @imap.search(["UNSEEN"])
            if messages.empty?
               sleep 60
            else
               msg = messages[0]
               mails = @imap.fetch msg, "BODY[TEXT]"
               msg = mails[0].attr["BODY[TEXT]"]
               return msg.gsub "\r\n", ""
            end
         end
      end
      until false 
      #   begin
            return reader.call
       #  rescue
          #  log "Could not receive IMAP messages", "Attempting to reconnect" 
         #   connect
        # end
      end
   end

end
