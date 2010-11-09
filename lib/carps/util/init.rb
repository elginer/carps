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

require "carps/util/windows"
require "carps/util/process"
require "carps/util/config"

require "erb"

# Don't do this if you're building the program
unless $IN_RAKE
   # Requiring this file cripples ERB 
   #
   # This is because it does not work with $SAFE = 1
   # and this is not checked by highline
   class ERB

      def initialize str, *args
         @res = str
      end

      def result *args
         @res
      end

   end
end

module CARPS

   # Set up multi-threading
   #
   # Can be called more than once
   def CARPS::init_threading
      Thread.abort_on_exception = true
   end

   # The root config directory
   #
   # This performs an untaint operation
   def CARPS::root_config
      loc = nil
      # If it's windows
      if CARPS::windows?
         loc = ENV["USERPROFILE"]
      else
         # Otherwise assume it's a unix-like system
         loc = ENV["HOME"]
      end
      if loc
         loc += "/carps/"
         loc.untaint
      else
         CARPS::fatal "Could not find home directory."
      end
   end

   # Set the configuration directory
   def CARPS::config_dir dir
      $CONFIG = CARPS::root_config + dir + "/"
   end

   # Initialize carps
   #
   # Optionally set the config_dir at the same time
   #
   # Sets $SAFE to safe, default 1
   #
   # FIXME:  instead of setting a global variable, should use the singleton pattern
   def CARPS::init safe=1, dir=nil

      $SAFE = safe
      if dir
         config_dir dir
      end
      CARPS::init_threading
   end 

end
