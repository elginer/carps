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

require "carps/service"

require "carps/protocol"

require "carps/ui"

require "carps/util"

require "drb"

module CARPS

   # Server game
   class GameServer

      # The first parameter is email account information.
      # The second is the mod.
      # The third is the description.
      # The fourth is the session key
      # The fifth is the configuration file
      def initialize mod, campaign, desc, session, conf
         @campaign = campaign
         @mod = mod
         @about = desc
         @session = session
         @conf = conf
      end

      # Set the dm
      def dm= master
         @dm = master
      end

      # Invite players to this game and begin
      #
      # FIXME: Just use 'play'
      def start mailer
         play mailer
      end

      # Resume this game
      #
      # FIXME: just use 'play'
      def resume mailer
         play mailer
      end

      private

      def play mailer
         mod = load_mods[@mod]
         dm_mailer = DM::Mailer.new mailer, @conf, @session, @dm, @mod, @desc
         thrd = $process.launch dm_mailer, mod + " -h \"" + @campaign + "\""
         thrd.join
      end

   end

   # Client games
   class GameClient

      # The first parameter is the dungeon master's name
      # The second is the mod.
      # The third is the configuration file
      def initialize dm, mod, conf
         @dm = dm
         @mod = mod
         @conf = conf
      end

      # Join this game as a client
      def join_game mailer
         resume mailer
      end

      # Play the game
      def resume mailer
         mod = load_mods[@mod]
         player_mailer = Player::Mailer.new @dm, mailer, @conf
         thrd = $process.launch player_mailer, mod + " -p"
         thrd.join
      end

   end


end
