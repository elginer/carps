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

require "carps/mod/mod"
require "carps/mod/character_sheet"
require "carps/mod/sheet_editor"
require "carps/mod/client_turn"

require "carps/util/error"
require "carps/util/highlight"

module CARPS

   module Player

      # Player mod
      class Mod < CARPS::Mod

         def initialize pmailer
            @mailer = pmailer
            @sheet = CharacterSheet.new({})
            edit_sheet
         end

         # Edit the character sheet
         def edit_sheet
            edit = SheetEditor.new schema, semantic_verifier
            @sheet = edit.fill @sheet.dump
            @edited = true
         end

         # Show the character sheet
         def show_sheet
            @sheet.display
         end

         # Take a turn
         def take_turn
            if @turn
               @answers = @turn.take
            else
               tu = @mailer.check ClientTurn
               if tu
                  @turn = tu
                  sheet = @turn.sheet
                  unless sheet.dump.empty?
                     @sheet = sheet
                     UI::highlight "Received new character sheet."
                  end
                  @answers = @turn.take
               else
                  UI::put_error "Turn not received."
               end
            end
         end

         # Send answers to dungeon master
         def next_turn
            if @answers
               @mailer.relay @answers
               @turn = nil
               done = true
            end
            if @edited
               @edited = false
               @mailer.relay @sheet
               done = true
            end
            unless done
               UI::put_error "Nothing to send."
            end
         end

      end

   end

end
