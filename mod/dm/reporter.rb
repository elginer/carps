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

require "util/editor"

# Used by the dungeon master to generate reports
#
# Subclasses should override the "player_turn" method
class Reporter

   def initialize
      @status = {}
      @questions = {}
   end

   # Add a new player
   def add_player moniker
      @status[moniker] = nil
      @questions[moniker] = []
   end

   # Produce a ClientTurn for the player referred to by the moniker
   def player_turn moniker
      status = StatusReport.new @status[moniker]
      ClientTurn.new status, @questions[moniker]
   end

   # Take a hash of monikers to email addresses
   #
   # Produce a hash of email address to ClientTurn objects
   def player_turns
      turns = {}
      monikers = @status.keys
      monikers.each do |moniker|
         turns[moniker] = player_turn moniker 
      end
      turns
   end

   # Edit the report for a player 
   def edit player
      editor = Editor.new "editor.yaml"
      @status[player] = editor.edit @status[player]
   end

   # Inform the reporter of updates to a player's status report
   def update_player player, status
      @status[player] = status
   end

   # Inform the reporter of updates to everyone's status
   def update_everyone status
      @status.each_key do |moniker|
         @status[moniker] = status
      end
   end

   # Ask a player some questions
   def ask_player moniker, questions
      @questions[moniker] = questions
   end

   # Ask everyone some questions
   def ask_everyone questions
      @questions.each_key do |moniker|
         @questions[moniker] = questions
      end
   end

end
