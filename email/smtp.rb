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


require "net/smtp"
require "socket"

require "util/log.rb"

# SMTP connection
class SMTP
   
   # Connect to the server with username and password
   def initialize settings, user, password
      @port = settings["port"]
      @username = user
      @password = password
      @server = settings["server"]
      @starttls = settings["starttls"]
      connect
   end

   def connect
      until false 
         puts "Making SMTP connection for " + @username
         puts "Server: #{@server}, Port: #{@port}"
         begin
            # Create smtp object
            @smtp = Net::SMTP.new @server, @port 
            if @starttls
               # Use an encrypted connection
               @smtp.enable_starttls
            end
            @smtp.start Socket.gethostname, @username, @password
            return
         rescue
            log "Could not connect to SMTP server", "Attempting to reconnect in 10 seconds."
            sleep 10
         end
      end
   end

   # Send an email message
   def send to, message 
      until false
        # begin
            @smtp.send_message "Content-Type: application/octet-stream\r\n" + message, @username, [to] 
            return 
        # rescue
         #   log "Could not send email with SMTP", "Attempting to reconnect"
          # connect
       #  end
      end
   end
end
