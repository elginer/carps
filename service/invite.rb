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


require "service/mod"
require "protocol/message"

# An invitation
class Invite < Message

   # We are part of the protocol :)
   protoword "invite"

   def initialize from, game_info
      @game_info = game_info
      super from
   end

   def Invite.parse from, blob
      forget, blob = find K.invite, blob
      info, blob = GameClient.parse blob
      [Invite.new(from, info), blob]
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

end
