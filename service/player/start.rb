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

require "service/game"

# Interface for the player to join games
class PlayerStartInterface < StartGameInterface

   def initialize continuation, mailer, game_config, message_parser
      super
      add_command "wait", "Wait for an invitation to join a game."
   end

   private

   def wait
      puts "Waiting for an invitation from a DM."
      invite = @mailer.read Invite
      if invite.ask
         @continuation.call lambda {invite.accept @mailer}
      end
   end

end
