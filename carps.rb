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


require "email/config"

require "crypt/mailer"

require "service/game/config"

require "service/server_parser"

require "util/error"
require "util/init"
require "util/files"

# Choose which game we are to play
def choose_game
   games_dir = $CONFIG + "/games"
   game_files = files games_dir 
   if game_files.empty?
      fatal "You need to create a game inside the games directory first."
   end
   games = game_files.map do |game_file|
      GameConfig.new game_file
   end
   if games.size == 1
      game = games[0]
      puts "The only game available is:"
      puts "\n"
      game.display
      puts "\n"
      return game
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
   # Evil testing
   # $evil = true
   init "server"
   # Choose game
   game_config = choose_game
   # Load email account
   account = EmailConfig.new server_parser 
   # Get the mailer
   mailer = account.mailer
   # We can create the game as soon as we have the mailer 
   game = game_config.spawn mailer
   # Invite players
   game.start_game
end
