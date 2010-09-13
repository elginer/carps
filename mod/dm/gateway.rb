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

require "mod/dm/reporter"

require "util/editor"

# Interface between the mod and the low level dm resources
class Gateway
   
   # Initialize with a resource manager, and a DM mod
   def initialize resource, mod
      @editor = Editor.new "editor.yaml" 
      @mod = mod
      mod.gateway = self
      @resource = resource
      @reporter = Reporter.new resource
      wait_for_responses
   end

   # A new player joins
   def new_player email
      @mod.add_player email
   end

   # Edit the report for a player 
   def edit player
      @reporter.edit player, @editor
   end

   # Set the report to be sent to a player 
   def update_player player, status
      @reporter.update_player_status player, status
   end

   # Set the report to be sent to all players
   def update_global status
      @reporter.update_global_status status
   end

end
