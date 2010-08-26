require "service/mod"
require "protocol/message"

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

   # Ask if the player wants to accept this invitation
   def ask
      puts "You have been invited to a game!"
      unless load_mods.member? @game_info.mod
         puts "But it's for the mod: " + @game_info.mod
         puts "Which you don't have installed."
         return false
      end
      @game_info.display
      puts "Do you want to join? (Type anything beginning with y to join)"
      gets[0] == "y"
   end

   # Accept the invitation
   def accept account
      @game_info.join_game account
   end

   def emit 
      K.invite + @game_info.emit
   end

   def type
      :invite
   end

end
