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

require "carps/mod"

require "carps/util/editor"

module CARPS

   module DM

      # A basic user interface for the dm
      #
      # Subclass this interface to provide commands
      class Interface < CARPS::RolePlayInterface

         def initialize mod
            super()
            @mod = mod
            add_command :mail, "Check for new emails."
            add_command :save, "Saves the state of the world."
            add_command :done, "Send all reports and start the next turn."
            add_command :invite, "Invite a new player", "EMAIL"
            add_command :describe, "Describe a player or an NPC.", "PLAYER/NPC"
            add_command :players, "Describe all players."
            add_command :npcs, "Describe all NPCs."
            add_command :edit, "Edit a character sheet belonging to a player or NPC.", "PLAYER/NPC"
            add_command :warp, "Put all player in this room.", "ROOM"
            add_command :room, "Put one player in this room.", "PLAYER", "ROOM"
            add_command :spawn, "Create a new npc", "TYPE", "NAME"
            add_command :decree, "Create a report for all players to see."
            add_command :tell, "Tell a player something.", "PLAYER"
            add_command :census, "Ask a question of every player."
            add_command :ask, "Ask a question of one player.", "PLAYER"
            add_command :survey, "Preview the reports and questions to be sent to every player."
            add_command :inspect, "Preview the report and questions to be sent to one player.", "PLAYER"
            add_command :nuke, "Clear all reports and questions for all players."
            add_command :silence, "Clear all reports for all players."
            add_command :futile, "Clear all questions for all players."
            add_command :remit, "Clear the report for one player", "PLAYER"
            add_command :supress, "Clear the questions for one player", "PLAYER"
         end

         protected

         # Invite a new player
         def invite addr
            @mod.invite addr
         end

         # Quit, but save first
         def quit
            save
            super
         end

         def save
            @mod.save
         end

         def done 
            @mod.next_turn
         end

         def edit name
            @mod.edit_sheet name
         end

         def npcs
            @mod.list_npcs
         end

         def players
            @mod.list_players
         end

         def describe name
            @mod.describe name 
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

         def decree
            @mod.create_global_report
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

         def census
            @mod.ask_everyone
         end

         def ask player
            @mod.ask_player player
         end

         def warp room 
            @mod.everyone_in room
         end

         def room player, room
            @mod.player_in player, room
         end

         def spawn type, name
            @mod.new_npc type, name
         end

         def tell player
            @mod.tell player
         end

      end

   end

end
