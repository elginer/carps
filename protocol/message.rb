require "util/log.rb"
require "service/game.rb"

require "crypt/handshake.rb"

# Parse, choosing from a number of alternative messages, return the first one that suceeds
def choose from, messages, blob
   messages.each do |message|
      begin
         result, blob = message.parse from, blob
         return [result, blob] 
      rescue Expected
      end
   end
   throw Expected.new messages 
end

# Parse a message from a block of unformatted text
# Subclasses must create a method called choices which is a list of classes supporting a parse method 
class MessageParser

   def system_choices
      [Handshake]
   end

   # Parse the text into a message 
   def parse from, text
      input = text
      begin
         msg, blob = choose from, (choices + system_choices), text 
         return msg
      rescue Expected
         log "An invalid email was received:", input
         return nil
      end
   end
end


# Receive messages for the client
class ClientParser < MessageParser
   def choices
      [Invite]
   end
end

# Receive messages for the server
class ServerParser < MessageParser
   def choices
      []
   end
end

# A message
class Message
   # We don't know what type the message will be when we ask for it, so we'll have to check
   def type
      nil
   end

   # Parse.
   #
   # The first parameter is the email address this text is from
   # The second parameter is the text itself.
   def parse from, text
      nil
   end

end
