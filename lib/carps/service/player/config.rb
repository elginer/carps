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

require "carps/util/config"
require "carps/service/game"

require "yaml"

module CARPS

   module Player

      # Class to read game configuration files
      class GameConfig < YamlConfig

         # Create a new GameConfig
         def initialize mod, dm, about
            @mod = mod
            @dm = dm
            @about = about
         end

         # Parse a game config file
         def parse_yaml conf
            @mod = read_conf conf, "mod"
            @about = read_conf conf, "about"
            @dm = read_conf conf, "dm"
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
            f = File.new($CONFIG + "/games/" + filename, "w")
            f.write emit
            f.close
         end

         # Spawn a game object so we can resume the game
         def spawn mailer
            GameClient.new mailer, @dm, @mod, @about
         end

         private

         # Emit as yaml
         def emit
            {"mod" => @mod, 
       "about" => @about, 
       "dm" => @dm}.to_yaml
         end

      end

   end

end
