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
      text = text.gsub "\r\n", ""
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

# An invitation
class Invite < ClientMessage

   # We are part of the protocol :)
   protoword "invite"

   def initialize game_info
      @game_info = game_info
   end

   def Invite.parse blob
      forget, blob = find K.invite, blob
      info, blob = GameClient.parse blob
      [Invite.new(info), blob]
   end

   # Interact with the player - ask if he wants to accept this invitation
   def speak account
      puts "You have been invited to a game!"
      @game_info.display
      puts "Do you want to join? (Type anything beginning with y to join)"
      join = gets
      if join[0] == "y"
         @game_info.join_game account
      end
   end

   def emit 
      K.invite + crlf + @game_info.emit
   end

   def type
      :invite
   end

end
