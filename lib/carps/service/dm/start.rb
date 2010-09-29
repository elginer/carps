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

require "service/start/interface"

require "util/editor"

# Interface for the dm to start games
class DMStartInterface < StartGameInterface

   def initialize continuation, mailer, game_config, message_parser
      super
      add_command "new", "Start a new game.", "NAME", "MOD", "CAMPAIGN"
   end

   protected

   def new name, mod, campaign
      editor = Editor.new "editor.yaml"
      about = editor.edit "<Replace with description of game>"
      players = get_players
      config = @game_config.new mod, campaign, about, players
      config.save name + ".yaml"
      game = config.spawn @mailer
      @continuation.call lambda {game.start}
   end

   def get_players
      pl = []
      done = false
      until done
         e = question "Enter email address of player to invite.  Leave blank for no more players."
         if e.empty?
            done = true
         else
            pl.push e
         end
      end
      pl
   end

end
