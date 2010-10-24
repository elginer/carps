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

require "carps/protocol"

require "carps/service"

require "carps/ui"

module CARPS

      # An invitation
   class Invite < Message

      # We are part of the protocol :)
      protoval :master
      protoval :mod
      protoval :about
      protoval :session

      def initialize dm, mod, about, session
         @dm = dm
         @mod = mod
         @about = about
         @session = session
      end

      # Parse this from semi-structured text
      def Invite.parse blob
         dm, blob = find K.master, blob
         mod, blob = find K.mod, blob
         about, blob = find K.about, blob
         session, blob = find K.session, blob
         [Invite.new(dm, mod, about, session), blob] 
      end

      # Ask if the player wants to accept this invitation,
      # join the game if they do
      def ask
         puts "You have been invited to a game!"
         if load_mods.member? @mod
            game = Player::GameConfig.new "", @mod, @dm, @about, @session 
            game.display
            if UI::confirm("Do you want to join?")
               filename = UI::question "Enter a file name for the game:"
               game.filename = filename
               game.save
               return game
            else
               return nil
            end
         else
            puts "But it's for the mod: " + @mod 
            puts "Which you don't have installed."
            return nil 
         end
      end

      def emit 
         V.master(@dm) + V.mod(@mod) + V.about(@about) + V.session(@session)
      end

   end

end
