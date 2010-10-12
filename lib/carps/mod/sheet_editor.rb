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

require "carps/util/error"

module CARPS

   # Editor for a character sheet
   class SheetEditor

      def initialize schema, semantics
         @schema = schema
         @semantics = semantics
      end

      # Fill in the sheet
      def fill current = {}
         editor = Editor.load
         sheet = create_sheet current
         filled = nil 
         until filled
            sheet = editor.edit sheet
            sheet_map = nil
            begin
               sheet_map = YAML.load sheet
            rescue ArgumentError => e
               puts e
            end
            character_sheet = CharacterSheet.new sheet_map 
            if valid?(character_sheet)
               filled = character_sheet
            end
         end
         filled
      end

      # Is the sheet valid?
      def valid? sheet
         failure = sheet.syntax_error @schema
         if failure
            UI::put_error "Character sheet was incorrect:"
            puts failure
            return false
         else
            return @semantics.verify sheet
         end
      end

      private

      # Create sheet text 
      def create_sheet current
         if current.empty?
            @schema.each_key do |field|
               current[field] = nil
            end
         end
         sheet = "# Character sheet\n"
         current.each do |field, value|
            type = @schema[field]
            sheet += "# #{field} is #{type}\n"
            sheet += "#{field}: #{value}\n"
         end
         sheet
      end

   end

end
