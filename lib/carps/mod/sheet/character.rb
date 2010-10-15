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

require "yaml"

module CARPS

   module Sheet

      # Allow the dungeon master to inspect and modify character sheets
      #
      # Supports syntactic and semantic verification
      class Character

         def initialize sheet = {}
            @sheet = sheet
         end

         # Display the sheet 
         def display
            puts @sheet.to_yaml
         end

         # Visit the sheet
         #
         # Takes a block
         def visit_sheet
            yield @sheet
         end

         # The sheet has no entries - it is uninitialized!
         def empty?
            @sheet.empty?
         end

      end

   end

end
