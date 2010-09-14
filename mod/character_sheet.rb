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

require "protocol/message"

require "util/editor"

require "mod/sheet_type"

require "yaml"

# A character sheet filled in by a player.
class CharacterSheet < Message

   # Extend the protocol
   protoval :character_sheet

   # Write the sheet 
   def initialize sheet
      @sheet = sheet
   end

   # Parse from the void
   def CharacterSheet.parse blob
      sheety, blob = find K.character_sheet, blob
      [CharacterSheet.new(YAML.load(sheety)), blob]
   end

   # Emit
   def emit
      V.character_sheet_request @sheet.to_yaml
   end

   # Display the sheet 
   def display
      puts @sheet.to_yaml
   end

   # Perform semantic analysis
   def verify_semantics verifyer
      valid = verifyer.verify @sheet
      if valid
         display
         return confirm "Is the above character sheet correct?"
      else
         return false
      end
   end

   # Verify the sheet's syntax.
   def verify schema
      mechanical_verify schema
   end

   private

   def mechanical_verify schema
      schema.each do |field, type|
         coerced = verify_type @sheet[field], type
         if coerced 
            @sheet[field] = coerced
         else
            return false
         end
      end
      return true
   end

   def verify_type val, type_str
      optional_math = type_str.match /^\s+optional\s+(\S+)\s+$/
      optional = false
      if optional
         type_str = optional_math[1]
         optional = true
      end
      type_str.downcase!
      type = TypeParser.parse optional, type_str
      type.verify val
   end

end
