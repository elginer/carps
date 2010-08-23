require "net/imap.rb"

# Administer IMAP connections
class IMAP

   # Connect to the server with username and password
   def initialize server, username, password
      @imap = Net::IMAP.new(server, 993, true)
      @imap.login(username, password)
      @imap.select("inbox")
   end

   # Return the next email message
   def read
      # Block 'till we get one
      while
         messages = @imap.search(["UNSEEN"])
         if messages.empty?
            sleep 60
         else
            msg = messages[0]
            body = @imap.fetch msg, "BODY[TEXT]"
            subject = @imap.fetch msg, "BODY[HEADER.FIELDS (Subject)]"
            from = @imap.fetch msg, "BODY[HEADER.FIELDS (From)]"
            return Email.new from, subject, body 
         end
      end
   end

end
