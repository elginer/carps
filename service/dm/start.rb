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

require "service/interface"

# Interface for the dm to start games
class StartGameInterface < Interface

   def initialize
      super
      add_command "new", "Start a new game.", "NAME", "MOD", "CAMPAIGN"
      add_command "games", "List existing games."
      add_command "load", "Load an existing game.", "NAME"
   end

end
