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

require "carps/service/game"
require "carps/service/start/config"

require "yaml"

module CARPS

   module Player

      # Class to read game configuration files
      class GameConfig < SessionConfig

         # Create a new GameConfig
         def initialize mod, dm, about, session
            super()
            @mod = mod
            @dm = dm
            @about = about
            @session = session
         end

         # Parse a game config file
         def parse_yaml conf
            @mod = read_conf conf, "mod"
            @about = read_conf conf, "about"
            @dm = read_conf conf, "dm"
            @session = read_conf conf, "session"
         end

         # Display information on this configuration
         def display
            puts "Mod: " + @mod
            puts "Description:"
            puts @about
            puts "DM: " + @dm
         end

         # Save this game
         def save filename
            save_file "games/" + filename
         end

         # Spawn a game object so we can resume the game
         def spawn
            GameClient.new @dm, @mod, @about
         end

         protected

         # Emit as hash 
         def emit
            puts "@about was #{@about}"
            {"mod" => @mod, 
             "about" => @about, 
             "dm" => @dm,
             "session" => @session}
         end

      end

   end

end
