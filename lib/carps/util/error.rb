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

require "carps/util/colour"

module CARPS

   # Output an error message and quit with exit code 1
   def fatal msg
      h = HighLine.new
      $stderr.write h.color("\nFATAL ERROR\n#{msg}\n", :error)
      if $!
         $stderr.write $!.to_s
      end
      puts "\a"
      exit 1
   end

   # Output an error message
   def put_error msg
      h = HighLine.new
      puts h.color("Error:  #{msg}", :error)
   end

end
