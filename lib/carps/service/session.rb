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

require "thread"

module CARPS

   # A session manager
   #
   # Its methods are reentrant
   class SessionManager

      def initialize
         @semaphore = Mutex.new
      end

      # Generate a new session from a key
      def generate key
         t = Time.new
         @semaphore.synchronize do
            @session = key + t.to_f.to_s
         end
         @session
      end

      # Set the current session
      def session= sess
         @semaphore.synchronize do
            @session = sess
         end
      end

      # Remove the current session
      def none
         @semaphore.synchronize do
            @session = nil
         end
      end

      # Is this message appropriate for the current session
      def belong? message
         @semaphore.synchronize do
            if @session
               message.session == @session
            else
               true
            end
         end
      end

      # Set a message's session
      def tag message
         @semaphore.synchronize do
            message.session = @session
         end
      end

   end

end
