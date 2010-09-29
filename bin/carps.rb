require "optparse"

require "carps"

include CARPS

# Set up the email
def setup_email parser
   config = EmailConfig.new "email.yaml"
   config.mailer parser
end

player = false
dm = false

opts = OptionParser.new do |opts|

   opts.banner = "Usage: carps [OPTION]"

   opts.separator ""
   opts.separator "Options:"

   opts.on "-p", "--player", "Use this option to play, or otherwise act as a player." do
      player = true
   end

   opts.on "-m", "--master", "Use this option to host a game, or otherwise act as a dungeon master." do
      dm = true
   end

   opts.on "-w", "--wizard", "Use this option to configure your settings.  Use with either -m or -p." do
      wizard = true
   end

   opts.on "-h", "--help", "Print help." do
      puts opts
      exit
   end
end

begin
   opts.parse! ARGV
rescue StandardError => e
   puts e.to_s
   puts opts
   exit 1
end

if player and not dm
   init "player"
   mailer = setup_email client_parser
   DMStartInterface.start_game_interface mailer, DMGameConfig
elsif dm and not player
   init "dm"
   mailer = setup_email server_parser
   PlayerStartInterface.start_game_interface mailer, PlayerGameConfig
else
   puts opts
   exit 1
end
