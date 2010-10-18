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

require "set"

module CARPS

   module Sheet

      # Types available in character sheets
      #
      # Subclasses must provide a method called valid, which takes a value and determines if it is valid.
      #
      # Subclasses may provide a method called coercion, which should return a symbol referring to a method which coerces a value into a different type (example, :to_s)
      #
      # Subclasses may provide a method called empty which should determine if a value is empty
      class Type

         def initialize optional
            @optional = optional
         end

         def verify val
            ok = false
            if coercion
               ok = valid(val) && val.respond_to?(coercion)
            else
               ok = valid(val)
            end
            if val == nil
               if @optional
                  return [true, nil]
               end
            elsif ok
               if empty(val) and @optional
                  return [true, nil]
               else
                  coerced = nil
                  if coercion
                     coerced = val.send coercion
                  else
                     coerced = val
                  end
                  [true, coerced]
               end
            else
               [false, nil]
            end
         end

         # No coercion
         def coercion
         end

         # Can't be empty
         def empty val
            false
         end

      end

      # Accept Fixnums
      class Int < Type

         def valid val
            val.class == Fixnum
         end

         def coercion
            :to_i
         end

      end

      # Accept Strings
      class Text < Type

         def valid val
            true
         end

         def coercion
            :to_s
         end

         def empty val
            if val.class == String
               return val.empty?
            else
               return false
            end
         end

      end

      # Accept one of a Set of possible values
      class Choice < Type

         # The second argument is the Set of possible values
         def initialize optional, choices
            super optional
            @choices = choices
         end

         # Only true for a member of the Set of possible values
         def valid val
            @choices.member? val.downcase
         end

      end

      # Accept booleans
      class Bool < Type

         # Only true for if val.class is TrueClass or FalseClass
         def valid val
            val.class == TrueClass or val.class == FalseClass
         end

      end

      # Parse the sheet types from strings
      class TypeParser
         def TypeParser.parse type_name
            type_name.downcase!
            optional_match = type_name.match /^\s*optional\s+((\S+\s+)*?\S+)\s*$/
               optional = false
            if optional_match
               type_name = optional_match[1]
               optional = true
            end
            if type_name == "integer"
               return Int.new optional 
            elsif type_name == "text"
               return Text.new optional
            elsif type_name == "boolean"
               return Bool.new optional
            elsif match = type_name.match(/^choice (.+)$/)
               choices = Set.new match[1].split
               return Choice.new optional, choices
            else
               raise StandardError, "Could not parse type name: " + type_name
            end
         end
      end

   end

end
