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
      V.character_sheet @sheet.to_yaml
   end

   # Display the sheet 
   def display
      puts @sheet.to_yaml
   end

   # Perform semantic analysis
   def verify_semantics verifyer
      valid = verifyer.verify self 
      unless valid
         puts "Invalid character sheet."
      end
      valid
   end

   # Verify the sheet's syntax.
   def syntax_error schema
      schema.each do |field, type|
         valid, coerced = verify_type @sheet[field], type
         if valid
            @sheet[field] = coerced
         else
            return field + " was not " + type
         end
      end
      return nil
   end

   # Dump the sheet!
   def dump
      @sheet
   end

   private

   def verify_type val, type_str
      type = TypeParser.parse type_str
      type.verify val
   end

end
