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
   # Game object that can communicate with players 
   def publish account
      Game.new account, @mod, @about, @players
   end

end
