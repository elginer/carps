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

   module DM
      # Class to read game configuration files
      class GameConfig < UserConfig

         # Create a new GameConfig
         def initialize mod, campaign, about, players
            @campaign = campaign
            @mod = mod
            @about = about
            @players = players
         end

         # Parse a game config file
         def parse_yaml conf
            @campaign = read_conf conf, "campaign"
            @mod = read_conf conf, "mod"
            @about = read_conf conf, "about"
            @players = read_conf conf, "players"
         end

         # Display information on this configuration
         def display
            puts "Mod: " + @mod
            puts "Campaign: " + @campaign
            puts "Description:"
            puts @about
            puts "Invited players:"
            puts @players
         end

         # Save this game
         def save filename
            save_file $CONFIG + "/games/" + filename
         end

         protected

         # Emit as hash 
         def emit
            {"mod" => @mod, 
             "campaign" => @campaign, 
             "about" => @about, 
             "players" => @players}
         end

         # Receive a mailer 
         # Return a GameServer object that can communicate with players 
         def spawn mailer
            GameServer.new mailer, @mod, @campaign, @about, @players
         end

      end

   end

end
