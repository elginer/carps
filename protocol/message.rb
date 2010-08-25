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

   # Decode the text into a class and its arguments
   def decode text
      input = text
      text = text.gsub "\r\n", ""
      begin
         forget, after = text.find init, 2
         klass, blob = choose choices, after 
         msg, rest = klass.parse blob
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
      [[carp_invite,Invite]]
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

# An invitation
class Invite < ClientMessage

   def initialize game_info
      @game_info = game_info
   end

   def Invite.parse blob
      forget, blob = find carp_invite, blob
      info, blob = Game.parse blob
      [Invite.new(info), blob]
   end

   def emit 
      carp_invite @game_info.emit
   end

   def type
      :invite
   end

end
