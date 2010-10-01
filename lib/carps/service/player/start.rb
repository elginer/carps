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

require "carps/service/start/interface"

require "carps/service/game"

require "carps/util/question"

module CARPS

   module Player

      # Interface for the player to join games
      class StartInterface < StartGameInterface

         def initialize continuation, mailer, game_config
            super
            add_command "mail", "Check for mail."
         end

         protected

         def mail 
            invite = @mailer.check Invite
            if invite
               if invite.ask
                  config = @game_config.new invite.mod, invite.dm, invite.desc
                  fn = question "Enter a name for this game"
                  fn = fn + ".yaml"
                  config.save fn
                  @continuation.call lambda {invite.accept}
               end
            elsif shake = @mailer.check_handshake
               @mailer.handle_handshake shake
            else
               puts "No new mail."
            end
         end

      end

   end

end
