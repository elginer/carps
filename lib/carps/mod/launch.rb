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

require "drb"

require "carps/util"

require "carps/ui"

module CARPS

   # Functions which launch mods.
   module Launcher

      # Print an error message
      def Launcher::usage
         puts "Mod requires argument -p URI for player\nor -h CAMPAIGN URI for DMs."
         CARPS::enter_quit 1
      end

      def Launcher::get_mailer uri
         DRb.start_service
         mailer = DRbObject.new_with_uri uri
      end

      # Either get the mod from the mailer or create a new one
      def Launcher::launch_player_mod role, mailer, *args 
         mod = nil
         if mod = mailer.load
            mod.mailer = mailer
         else
            mod = role.create_mod mailer
         end
         role.launch mod
      end

      # Either get the mod from the mailer or create a new one
      def Launcher::launch_dm_mod role, campaign, mailer
         mod = nil
         if mod = mailer.load
            mod.mailer = mailer
         else
            mod = role.create_mod campaign, mailer
         end
         role.launch mod
      end

      # Use to launch a mod
      #
      # Pass a module, containing the mod: this will do the rest.
      #
      # The module must contain two further modules, Player and DM
      #
      # Each of Player and DM must also contain a create_mod method (And I mean defined like `def Player::create_mod`).
      #
      # Player::create_mod should take one parameter: the mailer.
      #
      # DM::create_mod should take two parameters: the campaign, then the mailer.
      #
      # Each of Player and DM should also contain a launch method (which should be defined as per above),
      # this method should take one parameter: the mod
      def Launcher::launch mod

         CARPS::with_crash_report do
            # Should use optparse?
            if ARGV.empty?
               usage
            else
               role = ARGV.shift
               if role == "-h"
                  if ARGV.length == 2
                     CARPS::config_dir "dm"
                     campaign = ARGV.shift
                     Launcher::launch_dm_mod mod::DM, campaign, Launcher::get_mailer(ARGV.shift)
                  else
                     usage
                  end
               elsif role == "-p"
                  if ARGV.length == 1
                     CARPS::config_dir "player"
                     Launcher::launch_player_mod mod::Player, Launcher::get_mailer(ARGV.shift)
                  else
                     Launcher::usage
                  end
               else
                  Launcher::usage
               end
            end
         end
      end

   end

end
