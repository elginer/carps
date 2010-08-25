require "protocol/message.rb"
require "net/imap.rb"

# Administer IMAP connections
class IMAP

   # Connect to the server with username and password
   def initialize server, username, password, message_factory
      begin
         puts "Making IMAP connection to " + username
         @imap = Net::IMAP.new(server, 993, true)
         @imap.login(username, password)
         @imap.select("inbox")
      rescue
         fatal "Could not connect to IMAP server"
      end
      @factory = message_factory
   end

   # Return the next email message
   def read
      # Block 'till we get one
      while true
         messages = @imap.search(["UNSEEN"])
         if not messages.empty?
            msg = messages[0]
            body = @imap.fetch msg, "BODY[TEXT]"
            msg = @factory.parse
            # U HAS MALE
            puts "\a"
            if msg != nil
               return msg
            end
            sleep 60
         end
      end
   end

end
