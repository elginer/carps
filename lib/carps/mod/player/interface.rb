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

      # Player interface
      class Interface < CARPS::RolePlayInterface

         def initialize mod
            super()
            @mod = mod
            add_command "act", "Take your turn."
            add_command "save", "Save the game."
            add_command "done", "Send your stuff to the dungeon master and await the next turn."
            add_command "sheet", "Look at your character sheet."
            add_command "edit", "Edit your character sheet."
         end

         # Output information about the game, then run.
         def run
            puts @mod.description
            UI::question "Press enter when you are ready to fill in your character sheet."
            edit
            super
         end

         protected

         def save
            @mod.save
         end

         def sheet
            @mod.show_sheet
         end

         def edit
            @mod.edit_sheet
         end

         def act
            @mod.take_turn
         end

         def done
            @mod.next_turn
         end

      end

   end

end
