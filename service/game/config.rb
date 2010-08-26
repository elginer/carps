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


require "yaml"

require "util/config.rb"
require "service/game.rb"

# Class to read game configuration files
class GameConfig < YamlConfig

   # Parse a game config file
   def parse_yaml conf
      @mod = read_conf conf, "mod"
      @about = read_conf conf, "about"
      @players = read_conf conf, "players"
   end

   # Display information on this configuration
   def display
      puts "Mod: " + @mod
      puts "Description:"
      puts @about
      puts "Invited players:"
      puts @players
   end

   # Receive email account information and return a
   # GameServer object that can communicate with players 
   def publish account
      GameServer.new account, @mod, @about, @players
   end

end
