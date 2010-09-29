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
require "mod/character_sheet"

require "util/editor"

# Used by the dungeon master to generate reports
#
# Subclasses should override the "player_turn" method
class Reporter

   def initialize
      @status = {}
      @questions = {}
      @sheets = {}
   end

   # Produce a ClientTurn for the player referred to by the moniker
   def player_turn moniker
      report = @status[moniker]
      unless report
         report = ""
      end
      status = StatusReport.new report 
      qtext = @questions[moniker]
      unless qtext
         qtext = []
      end
      questions = qtext.map {|q| que = Question.new q}
      sheet = @sheets[moniker]
      unless sheet
         sheet = CharacterSheet.new({})
      end
      ClientTurn.new sheet, status, questions 
   end

   # Produce a hash of email address to ClientTurn objects
   def player_turns monikers
      turns = {}
      monikers.each do |moniker|
         turns[moniker] = player_turn moniker 
      end
      turns
   end

   # A character sheet has been changed
   def sheet moniker, sheet
      @sheets[moniker] = sheet
   end

   # Edit the report for a player 
   def edit player
      editor = Editor.new "editor.yaml"
      stat = @status[player]
      unless stat
         stat = ""
      end
      @status[player] = editor.edit stat
   end

   # Inform the reporter of updates to a player's status report
   def update_player player, status
      @status[player] = status
   end

   # Ask a player some questions
   def ask_player moniker, question
      if @questions.member? moniker
         @questions[moniker].push question
      else
         @questions[moniker] = [question]
      end
   end

   # Delete reports
   def delete_reports
      @status = {}
   end

   # Delete all questions for a player
   def delete_questions moniker
      @questions.delete moniker 
   end

   # Delete all questions for all players
   def delete_all_questions
      @questions = {}
   end

end
