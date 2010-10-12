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

require "carps/util/process"
require "carps/util/config"

require "etc"

# The root config directory
def root_config
   Etc.getpwuid.dir + "/carps/"
end

# Set the configuration directory
def config_dir dir
   $CONFIG = root_config + dir + "/"
end

# Initialize carps
#
# Optionally set the config_dir at the same time
#
# Initialize a CARPS::Process object into the global variable $process.
#
# FIXME:  instead of setting a global variable, should use the singleton pattern
def init dir=nil
   if dir
      config_dir dir
   end
   $process = CARPS::Process.load
   init_threading
end 
