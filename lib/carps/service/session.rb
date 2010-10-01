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

   # A session manager
   class SessionManager

      # Generate a new session from a key
      def new key
         t = Time.new
         @session = key + t.to_f.to_s
      end

      # Set the current session
      def session= sess
         @session = sess
      end

      # Remove the current session
      def none
         @session = nil
      end

      # Is this message appropriate for the current session
      def belong? message
         if @session
            message.session == @session
         else
            true
         end
      end

      # Set a message's session
      def tag message
         message.session = @session
      end

   end

end
