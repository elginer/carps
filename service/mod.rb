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


# Load the available mods 
def load_mods
   mod_list = (Dir.open "mods").entries.reject do |filename|
      filename[0] == "." and File.ftype(filename) == "directory"
   end
   mods = {} 
   mod_list.each do |mod_name|
      mods[mod_name] = "mods" + mod_name
   end
   mods
end

# Mod information struct, to be provided as a drb service to mods
ModInfo = Struct.new :mailer, :dm
