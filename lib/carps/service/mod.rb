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

require "drb"

require "yaml"

# Load the available mods 
def load_mods
   mod_file = $ROOT_CONFIG + "/mods.yaml"
   mods = {}
   begin
       mods = YAML.load(File.read mod_file)
   rescue
      warn "Cannot find mods: could not read #{mod_file}"
   end
   mods
end
