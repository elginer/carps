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

require "carps/service/mod"

require "carps/service/player/mailer"

require "carps/service/dm/mailer"

require "carps/protocol/keyword"
require "carps/protocol/message"

require "carps/util/question"

require "carps/util/process"

require "drb"

module CARPS

   # A game
   # Subclasses must write the variables @dm, @mod, @about in their constructors
   class Game < Message

      # We add a few things to the protocol
      protoval "master"

      protoval "mod"

      protoval "about"

      # Print game information
      def display
         puts "Game master: " + @dm
         puts "Mod: " + @mod
         puts "Description:"
         puts @about
      end

      # Emit this as semi-structured text
      def emit
         (V.master @dm) + (V.mod @mod) + (V.about @about)
      end  
   end

   # Server game
   class GameServer < Game

      # The first parameter is email account information.
      # The second is the mod.
      # The fourth is the description.
      # The fifth is a list of email addresses of players to be invited
      def initialize mod, campaign, desc, players
         @campaign = campaign
         @mod = mod
         @about = desc
         @players = players
      end

      # Set the dm
      def dm= master
         @dm = master
      end

      # Invite players to this game and begin
      def start mailer
         Thread.fork do
            # Perform handshakes
            @players.each do |player|
               # Handshakes are done asychronously
               thr = mailer.handshake player
               if thr
                  thr.join
               end
               invite = Invite.new @dm, @mod, @about
               mailer.send player, invite
            end
         end
         play mailer
      end

      # Resume this game
      def resume mailer
         play mailer
      end

      private

      def play mailer
         mod = load_mods[@mod]
         dm_mailer = DM::Mailer.new mailer
         thrd = $process.launch dm_mailer, mod + " -h '" + @campaign + "'"
         thrd.join
      end

   end

   # Client games
   class GameClient < Game

      # The first parameter is the dungeon master's name
      # The second is the mod.
      # The third is the description.
      def initialize dm, mod, desc
         @dm = dm
         @mod = mod
         @about = desc
      end

      # Join this game as a client
      def join_game mailer
         resume mailer
      end

      # Play the game
      def resume mailer
         mod = load_mods[@mod]
         player_mailer = Player::Mailer.new @dm, mailer
         thrd = $process.launch player_mailer, mod + " -p"
         thrd.join
      end

   end

   # An invitation
   class Invite < Message

      # We are part of the protocol :)
      protoword "invite"

      def initialize dm, mod, about
         @dm = dm
         @mod = mod
         @about = about
      end

      # Parse this from semi-structured text
      def Invite.parse blob
         dm, blob = find K.master, blob
         mod, blob = find K.mod, blob
         about, blob = find K.about, blob
         [Invite.new(dm, mod, about), blob] 
      end

      # Ask if the player wants to accept this invitation
      #
      # If true, return a new game_config_class object, passing the session to it
      def ask game_config_class, session
         puts "You have been invited to a game!"
         if load_mods.member? @mod
            @game = game_config_class.new @mod, @dm, @about, session 
            @game.display
            if confirm("Do you want to join?")
               return @game
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
         K.invite + @game.emit
      end

   end

end
