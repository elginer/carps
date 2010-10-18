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

require "carps/ui"

module CARPS


   module Sheet

      # Editor for a character sheet
      #
      # Performs validations also, popping open an editor if they fail
      class Editor

         def initialize schema, semantics
            @schema = schema
            @semantics = semantics
         end

         # Fill in the sheet
         def fill current=Character.new
            sheet = create_sheet_text current
            validate sheet
            sheet
         end

         # Edit the sheet until it is valid
         def validate sheet
            vaild = false
            until valid
               failure = sheet.visit {|stats| @schema.produce_errors stats}
               unless failure
                  failure = sheet.visit {|stats| @semantics.produce_errors stats}
               end
               if failures
                  UI::put_error "Character sheet was incorrect:"
                  failures.each do |f|
                     puts f
                  end
                  sheet = edit sheet
               end
            end
            sheet
         end

         private

         # Edit the sheet
         def edit sheet
            sheet_text = create_sheet_text sheet
            sheet_map = nil
            begin
               editor = CARPS::Editor.load
               sheet_text = editor.edit sheet_text
               sheet_map = YAML.load sheet_text
            rescue ArgumentError => e
               put_error e.message
            end
            if sheet_map
               Character.new sheet_map
            end
         end

         # Create sheet text 
         def create_sheet_text user_sheet
            user_sheet.visit do |current|
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
               return sheet
            end
         end

      end

   end

end
