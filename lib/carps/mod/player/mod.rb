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

require "carps/ui"

module CARPS

   module Player

      # Player mod
      #
      # subclasses should provide a method called description
      #
      # description should return a string, a summary of the game.
      # Who wrote it, owns the copyright and where to find the rules 
      # are appropriate facts.
      class Mod < CARPS::Mod

         def initialize
            @sheet = Sheet::Character.new({})
         end

         # Edit the character sheet
         def edit_sheet
            editor.fill @sheet
            @edited = true
         end

         # Show the character sheet
         def show_sheet
            puts @sheet.emit
         end

         # Save the game
         def save
            @mailer.save self
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
            save
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
               @mailer.relay Sheet::NewSheet.new @sheet.attributes
               done = true
            end
            unless done
               UI::put_error "Nothing to send."
            end
            save
         end

      end

   end

end
