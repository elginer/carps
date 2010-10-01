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

require "carps/util/warn"
require "carps/util/error"
require "carps/email/string"

require "net/smtp"

require "socket"

module CARPS
   # SMTP connection
   class SMTP

      # Connects to the server
      def initialize settings, password
         @port = settings["port"]
         @username = settings["user"]
         @password = password
         @server = settings["server"]
         @starttls = settings["starttls"]
         @tls = settings["tls"]
      end

      # Are the settings okay?
      def ok?
         good = false
         begin
            with_attempt_connection {}
            good = true
         rescue StandardError => e
            put_error e.to_s
         end
         good
      end

      def with_attempt_connection &todo
         puts "Making SMTP connection for " + @username
         puts "Server: #{@server}, Port: #{@port}"
         # Create smtp object
         smtp = Net::SMTP.new @server, @port
         # Security measures
         if @starttls
            smtp.enable_starttls
         elsif @tls
            smtp.enable_tls
         end

         if not (@starttls or @tls) or @password.empty?
            warn "SMTP connection is insecure."
         end
         smtp.start Socket.gethostname, @username, @password, &todo
      end

      def with_connection &todo
         until false 
            begin
               with_attempt_connection &todo
               return
            rescue Net::SMTPAuthenticationError => e
               put_error e.to_s
               @password = secret "Enter SMTP password for #{@username}:"
            rescue
               warn "Could not connect to SMTP server", "Attempting to reconnect in 10 seconds."
               sleep 10
            end
         end
      end

      # Send an email message
      def send to, message
         with_connection do |smtp|
            message = to_mail "Content-Type: application/octet-stream\r\n" + message
            smtp.send_message message, @username, [to]
         end
      end

   end

end
