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


require "email/config.rb"
require "protocol/message.rb"

require "service/game/config.rb"
require "yaml"

# Choose which game we are to play
def choose_game
   game_files = Dir.open("games").entries.reject do |game_file|
      game_file[0] == "." or File.ftype("games/" + game_file) != "file" 
   end
   if game_files.empty?
      fatal "You need to create a game inside the games directory first."
   end
   games = game_files.map do |game_file|
      GameConfig.new "games/" + game_file
   end
   if games.size == 1
      return games[0]
   end
   games.each_index do |game_i|
      puts "\nGame number: #{game_i}"
      games[game_i].display
   end
   puts "\nEnter number of game to begin."
   games[gets.to_i]
end

# Carps server
def main
   # Choose game
   game_config = choose_game
   # Load email account
   account = EmailConfig.new "server_email.yaml", ServerParser.new
   # Give the game account information
   game_info = game_config.publish account
   # Invite players
   game_info.invite_players
   # Begin game
   game_info.start_game account
end
