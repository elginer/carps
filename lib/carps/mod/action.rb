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

module CARPS

   # Actions taken when a rule is applied. 
   #
   # Subclasses must provide methods:
   #
   # summary, returns string.  The idea is to describe the effects of this Action.
   #
   # execute which takes the dice result and then the parameters given to the Rule.  The idea is to manipulate them here.
   class Action

      def apply *params
         puts summary
         execute *params
      end

   end

end
