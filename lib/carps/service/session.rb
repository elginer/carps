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

require "carps/protocol/keyword"

require "thread"

module CARPS

   # A session manager
   #
   # It coordinates sessions between the game and the email system
   # The idea is to prevent a game from receiving messages
   # intended for another game.
   #
   # Its methods are reentrant
   class SessionManager

      # Extend the protocol for sessions
      protoval :session

      def initialize
         @session = ""
         @semaphore = Mutex.new
         @syms = (" ".."~").to_a
      end

      # Generate a number of random symbols 
      def randoms size
         ras = Array.new size do |forget|
            @syms[rand(95)]
         end
         ras.join
      end

      # Generate a new session from a key
      def generate key
         t = Time.new
         # It will be unlikely that anyone will guess this session
         ra = randoms 1000
         new_session = ra + key + t.to_f.to_s
         @semaphore.synchronize do
            @session = new_session 
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
            @session = "" 
         end
      end

      # Is this message appropriate for the current session
      def belong? message
         @semaphore.synchronize do
            if not message.session
               false
            elsif not @session.empty?
               message.session == @session
            else
               true
            end
         end
      end

      # Tag a string with a message 
      def tag message
         V.session(@session) + message
      end

   end

end
