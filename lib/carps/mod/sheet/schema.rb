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

module CARPS

   module Sheet
      
      # This isn't really the schema, but an object that wraps it
      # and uses it to perform syntactic validations on character sheets
      class Schema

         # Create a new schema
         def initialize schema
            @schema = schema
         end


         # Verify the sheet's syntax.
         #
         # Produce errors if it's invalid, nil if it's valid
         def produce_errors sheet
            errs = []
            @schema.each do |field, type|
               valid, coerced = verify_type sheet[field], type
               if valid
                  sheet[field] = coerced
               else
                  errs.push field + " was not " + type
               end
            end
            if errs.empty?
               nil
            else
               errs
            end
         end

         # Create sheet text for the user to edit 
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

         protected

         def verify_type val, type_str
            type = TypeParser.parse type_str
            type.verify val
         end


      end

   end

end
