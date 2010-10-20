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

require "carps/mod"

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
         def fill sheet=Character.new
            sheet = edit sheet
            validate sheet
         end

         # Is the sheet valid?
         def valid? sheet
            failures = sheet.visit {|stats| @schema.produce_errors stats}
            unless failures
               failures = sheet.visit {|stats| @semantics.produce_errors stats}
            end
            if failures
               UI::put_error "Character sheet was incorrect:"
               failures.each do |f|
                  puts f
               end
               return false
            else
               return true
            end
         end

         # Edit the sheet until it is valid
         def validate sheet
            valid = false
            until valid
               valid = valid? sheet
               unless valid
                  sheet = edit sheet
               end
            end
            sheet
         end

         private

         # Edit the sheet
         def edit sheet
            sheet_text = @schema.create_sheet_text sheet
            sheet_map = nil
            begin
               editor = CARPS::Editor.load
               sheet_text = editor.edit sheet_text
               sheet_map = YAML.load sheet_text
            rescue ArgumentError => e
               UI::put_error e.message
            end
            if sheet_map
               Character.new sheet_map
            end
         end

      end

   end

end
