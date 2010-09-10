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

require "mod/question"
require "mod/client_turn"
require "mod/status_report"

# Used by the dungeon master to generate reports
#
# Presents a facade, allowing the current room to be changed.
#
# Subclasses must provide "player_turn" method
#
# which takes a monikers (a string used to identify a player)
#
# and producees a ClientTurn object for that player
class Reporter

   def initialize
      @questions = []
   end

   def set_default_status
      unless @status
         @status = @room.describe
      end
   end

   def add_question que
      @questions.push Question.new que
   end

   def current_room room
      @room = room
   end

   def player_turn moniker
      status = StatusReport.new @status
      ClientTurn.new status, @questions
   end

   def player_turns monikers
      turns = {}
      set_default_status
      monikers.each do |moniker, mail|
         turns[mail] = player_turn moniker 
      end
      turns
   end

end
