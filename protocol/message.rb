require "util/log.rb"
require "service/game.rb"

# Parse, choosing from a number of alternative messages, return the first one that suceeds
def choose messages, blob
   messages.each do |message|
      begin
         result, blob = message.parse blob
         return [result, blob] 
      rescue Expected
      end
   end
   throw Expected.new messages 
end

# Parse a message from a block of unformatted text
# Subclasses must create a method called choices which is a list of classes supporting a parse method 
class MessageParser

   # Parse the text into a message 
   def parse text
      input = text
      begin
         msg, blob = choose choices, text 
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
   end
end

# A message
class Message
end

# A client message
class ClientMessage

   # We don't know what type the message will be when we ask for it, so we'll have to check
   # "Oh Johnny that's not very OO" - STFU!
   def type
      nil
   end
end
