require "net/smtp"
require "socket"

require "util/log.rb"
# TODO: very similar to IMAP code.  Refactor?
# Reasons why not:
# What would be abstracted away would be the control structures... 
# ..and we'd have to abstract them into essentially the SAME control structures
# SMTP connection
class SMTP
   
   # Connect to the server with username and password
   def initialize server, user, password
      @username = user
      @password = password
      @server = server
      connect
   end

   def connect
      until false 
         puts "Making SMTP connection for " + @username
         begin
            # Create smtp object
            @smtp = Net::SMTP.new @server, 587
            # Use an encrypted connection
            @smtp.enable_starttls
            @smtp.start Socket.gethostname, @username, @password
            return
         rescue
            log "Could not connect to SMTP server", "Attempting to reconnect"
         end
      end
   end

   # Send an email message
   def send to, message 
      until false
        # begin
            @smtp.send_message message.emit, @username, [to]
            return 
        # rescue
         #   log "Could not send email with SMTP", "Attempting to reconnect"
          # connect
       #  end
      end
   end
end
