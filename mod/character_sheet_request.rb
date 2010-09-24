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

require "mod/character_sheet"
require "mod/sheet_editor"

require "protocol/message"

require "util/editor"

require "yaml"

# A request for a character sheet to be filled in by the player.
class CharacterSheetRequest < Message

   # Extend the protocol
   protoval :character_sheet_request

   # Make the request 
   def initialize current = {}
      @current = current
   end

   # Parse from the void
   def CharacterSheetRequest.parse blob
      current, blob = find K.character_sheet_request, blob
      [CharacterSheetRequest.new(YAML.load(current)), blob]
   end

   # Emit
   def emit
      V.character_sheet_request @current.to_yaml
   end

   # Currently this sheet is 
   def currently
      @current
   end

end
