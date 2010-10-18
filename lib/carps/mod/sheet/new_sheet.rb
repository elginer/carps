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

require "carps/protocol/message"

require "carps/util/editor"

require "carps/mod/sheet_type"

require "yaml"

require "drb"

module CARPS

   module Sheet 
      # A character sheet filled in by a player.
      class NewSheet < Message

         # Extend the protocol
         protoval :character_sheet

         # Write the sheet 
         def initialize sheet
            @sheet = sheet
         end

         # Parse from the void
         def NewSheet.parse blob
            sheet, blob = find K.character_sheet, blob
            y = nil
            begin
               y = YAML.load sheet
            rescue ArgumentError => e
            end
            if y
               [NewSheet.new(y), blob]
            else
               raise Expected, "Expected valid YAML segment."
            end
         end

         # Emit
         def emit
            V.character_sheet @sheet.to_yaml
         end

         # Dump the sheet!
         def dump
            @sheet
         end

      end

   end

end
