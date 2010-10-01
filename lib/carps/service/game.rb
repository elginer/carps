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
      def initialize mailer, mod, campaign, desc, players
         @dm = mailer.address
         @campaign = campaign
         @mailer = mailer 
         @mod = mod
         @about = desc
         @players = players
      end

      # Invite players to this game and begin
      def start

         # Begin playing
         interface = play

         Thread.fork do
            # Perform handshakes
            @players.each do |player|
               # Handshakes are done asychronously
               thread = @mailer.handshake player
               if thread
                  thread.join
               end
               invite = Invite.new self

               @mailer.send player, invite
            end
         end
      end

      # Resume this game
      def resume
         play
      end

      private

      def play
         mod = load_mods[@mod]
         mailer = DM::Mailer.new @mailer
         $process.launch mailer, mod["host"] + " " + @campaign
      end

   end

   # Client games
   class GameClient < Game

      # The first parameter is the dungeon master's name
      # The second is the mod.
      # The third is the description.
      def initialize mailer, dm, mod, desc
         @mailer = mailer
         @dm = dm
         @mod = mod
         @about = desc
      end

      # Expose the mod so the client decide if he can even think of joining
      #
      # ANTI-PATTERN
      def mod
         @mod
      end

      # Expose the dm
      #
      # ANTI-PATTERN
      def dm
         @dm
      end

      # Expose the description
      #
      # ANTI-PATTERN
      def desc
         @desc
      end

      # Join this game as a client
      def join_game
         resume
      end

      # Parse this from semi-structured text
      def GameClient.parse blob
         dm, blob = find K.master, blob
         mod, blob = find K.mod, blob
         about, blob = find K.about, blob
         [GameClient.new(dm, mod, about), blob] 
      end

      # Play the game
      def resume
         mod = load_mods[@mod]
         main = mod["play"]
         mailer = Player::Mailer.new dm, @mailer
         $process.launch mailer, main
      end

   end

   # An invitation
   class Invite < Message

      # We are part of the protocol :)
      protoword "invite"

      def initialize game
         @game = game
      end

      def Invite.parse blob
         forget, blob = find K.invite, blob
         info, blob = GameClient.parse blob
         [Invite.new(info), blob]
      end

      # Expose the mod so the client decide if he can even think of joining
      #
      # ANTI-PATTERN
      def mod
         @game.mod
      end

      # Expose the dm
      #
      # ANTI-PATTERN
      def dm
         @game.dm
      end

      # Expose the description
      #
      # ANTI-PATTERN
      def desc
         @game.desc
      end

      # Ask if the player wants to accept this invitation
      def ask
         puts "You have been invited to a game!"
         unless load_mods.member? @game.mod
            puts "But it's for the mod: " + @game.mod
            puts "Which you don't have installed."
            return false
         end
         @game.display
         confirm "Do you want to join?"
      end

      # Accept the invitation
      def accept
         @game.join_game
      end

      def emit 
         K.invite + @game.emit
      end

   end

end
