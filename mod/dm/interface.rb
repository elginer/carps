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

require "service/interface"

require "util/editor"

# A basic user interface for the dm
#
# Subclass this interface to provide commands
class DMInterface < ControlInterface

   def initialize mod
      super()
      @mod = mod
      @editor = Editor.new "editor.yaml"
      add_command "mail", "Check for new emails."
      add_command "players", "List all players"
      add_command "warp", "Put all player in this room.", "ROOM"
      add_command "room", "Put one player in this room.", "PLAYER", "ROOM"
      add_command "npc", "Create a new npc", "TYPE", "NAME"
      add_command "edit", "Edit a player's report.", "PLAYER"
      add_command "census", "Ask a question of every player."
      add_command "ask", "Ask a question of one player.", "PLAYER"
      add_command "survey", "Preview the reports and questions to be sent to every player."
      add_command "inspect", "Preview the report and questions to be sent to one player.", "PLAYER"
      add_command "nuke", "Clear all reports and questions for all players."
      add_command "silence", "Clear all reports for all players."
      add_command "futile", "Clear all questions for all players."
      add_command "remit", "Clear the report for one player", "PLAYER"
      add_command "supress", "Clear the questions for one player", "PLAYER"
   end

   def mail
      @mod.check_mail
   end

   def supress player
      @mod.delete_questions player
   end

   def remit player
      @mod.delete_report player
   end

   def futile
      @mod.delete_all_questions
   end

   def silence
      @mod.delete_all_reports
   end

   def nuke
      silence
      futile
   end

   def inspect player
      @mod.inspect_turn player
   end

   def survey
      @mod.inspect_reports
   end

   def players
      @mod.list_players
   end

   def census
      question = @editor.edit "<Replace me with a question for everyone>"
      @mod.ask_everyone question
   end

   def ask player
      question = @editor.edit "<Replace me with a question for #{player}>"
      @mod.ask_player question
   end

   def warp room 
      @mod.everyone_in room
   end

   def room player, room
      @mod.player_in player, room
   end

   def npc type, name
      @mod.new_npc type, name
   end

   def edit player
      @mod.edit player
   end

end
