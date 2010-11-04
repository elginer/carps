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

require "carps/ui/colour"

module CARPS

   module UI

      # Output an error message
      #
      # If the second parameter is true, the error message will begin with
      # "Error:"
      def UI::put_error msg, default_error=true
         h = HighLine.new
         prelude = ""
         if default_error
            prelude = "Error:  "
         end
         $stderr.write h.color("#{prelude}#{msg}", :error)
         puts "\a"
      end

   end
end
