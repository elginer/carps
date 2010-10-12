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

require "carps/util/error"

module CARPS

   # Functions which launch mods.
   module Launcher

      # Print an error message
      def Launcher::usage
         puts "Mod requires argument -p URI for player\nor -h CAMPAIGN URI for DMs."
         CARPS::enter_quit 1
      end

      def Launcher::get_mailer uri
         mailer = nil
         begin
            DRb.start_service
            mailer = DRbObject.new_with_uri uri
         rescue StandardError => e
            UI::put_error "Error beginning IPC"
            CARPS::enter_quit 1
         end
      end

      # Either get the mod from the mailer or create a new one
      def Launcher::launch_mod role, mailer
         mod = nil
         if mod = mailer.load
            mod.mailer = mailer
         else
            mod = namespace::role.create_mod mailer
         end
         role.launch mod
      end


      # Use to launch a mod
      #
      # Pass a module, containing the mod: this will do the rest.
      #
      # The module must contain two further modules, Player and DM
      #
      # Each of Player and DM must also contain a create_mod method (And I mean defined like `def Player::create_mod`),
      # this method should take one parameter: the mailer
      #
      # Each of Player and DM should also contain a launch method (which should be defined as per above),
      # this method should take one parameter: the mod
      def Launcher::launch mod

         begin
            # Should use optparse?
            if ARGV.empty?
               usage
            else
               role = ARGV.shift
               if role == "-h"
                  if ARGV.length == 2
                     config_dir "dm"
                     Launcher::launch_mod mod::DM, Launcher::get_mailer(ARGV.shift) 
                  else
                     usage
                  end
               elsif role == "-p"
                  if ARGV.length == 1
                     config_dir "player"
                     Launcher::launch_mod mod::Player, Launcher::get_mailer(ARGV.shift)
                  else
                     Launcher::usage
                  end
               else
                  Launcher::usage
               end
            end
         rescue StandardError => e
            UI::put_error e.message + "\n" + e.backtrace.join("\n")
            CARPS::enter_quit
         end
      end

   end

end


