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

require "ostruct"

# Class providing references to characters
#
# Subclasses must override character method to return class of character
class Ch

   def Ch.create moniker, sheet
      klass = self.to_s
      self.class_eval <<-"END"
         char_sheet = #{sheet}
         @#{moniker} = #{klass}.character.new char_sheet
         def #{klass}.#{moniker}
            @#{moniker}
         end
      END
   end

   def Ch.character
      Character
   end

end

# Allow the dungeon master to inspect and modify character sheets
#
# Should be subclassed to support game rules
class Character < OpenStruct
end
