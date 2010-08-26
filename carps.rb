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
