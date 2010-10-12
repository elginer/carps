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

require "carps/util/config"

module CARPS

   # A configuration file for games which keeps track of sessions, 
   # and the mod's saved state
   class SessionConfig < UserConfig

      # Create from session ID and filename
      def initialize session, filename
         @session = session
         @filename = filename
      end

      # Set the session used by a session manager
      def register_session manager
         manager.session = @session
      end

      def parse_yaml conf
         @filename = read_conf conf, "filename"
         @session = read_conf conf, "session"
         @save = conf["save"]
      end

      # Save the mod
      #
      # Also saves the file
      def save_mod mod 
         @save = mod
         save 
      end

      # Load the mod
      def load_mod
         @save
      end

      # Save this game
      def save
         save_file "games/" + @filename + ".yaml"
      end

      protected

      def emit
         {"filename" => @filename,
         "save" => @save,
         "session" => @session}
      end

   end

end
