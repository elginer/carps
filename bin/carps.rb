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

require "optparse"

require "carps"

include CARPS

# Set up the email
def setup_email parser
   config = EmailConfig.new "email.yaml"
   config.mailer parser
end

# The user is a player
player = false
# The user is a dungeon master
dm = false
# The user is a n00b lol
noob = false

opts = OptionParser.new do |opts|

   opts.banner = "Usage: carps [OPTION]"

   opts.separator ""
   opts.separator "Options:"

   opts.on "-p", "--player", "Play a game." do
      player = true
   end

   opts.on "-m", "--master", "Host a game." do
      dm = true
   end

   opts.on "-w", "--wizard", "Use this option to configure your settings.  Use with either --master or --player." do
      noob = true
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
   if noob or PlayerWizard.first_time?
      player_wizard
      wizard = PlayerWizard.new
      wizard.run
   else
      mailer = setup_email client_parser
      DMStartInterface.start_game_interface mailer, DMGameConfig
   end
elsif dm and not player
   init "dm"
   if noob or MasterWizard.first_time?
      wizard = MasterWizard.new
      wizard.run
   else
      mailer = setup_email server_parser
      PlayerStartInterface.start_game_interface mailer, PlayerGameConfig
   end
else
   puts opts
   exit 1
end
