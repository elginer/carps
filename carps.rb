require "email/config.rb"
require "protocol/message.rb"

require "yaml"

# Choose which game we are to play
def choose_game
   game_files = Dir.open("games").entries.reject do |game_file|
      File.fttype "games/" + game_file != "file" 
   end
   game_files.map do |game_file|
      cs = YAML
   end
end

# Invite players
def invite_players
   invitees = []
   invite_player invitees
end

# Carps server
def main
   # Load email account
   account = EmailConfig.new "server_email.yaml", ServerParser, ServerMessage
   # Choose game
   game_info = choose_game 
   # Invite players
   invite_players account game_info
   # Begin game
   game_info.start_game account
end
