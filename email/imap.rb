require "protocol/message.rb"
require "util/log.rb"

require "net/imap.rb"


# Administer IMAP connections
class IMAP

   # Connect to the server with username and password
   def initialize server, username, password, parser
      @server = server
      @username = username
      @password = password
      @parser = parser
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

   # Return the next email message of a given type
   def read type
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
               body = mails[0].attr["BODY[TEXT]"]
               msg = @parser.parse body
               # U HAS MALE
               puts "\a"
               if msg != nil and msg.type == type
                  return msg
               end
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
