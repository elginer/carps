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

require "carps/mod/dm/room"

require "carps/util/warn"

require "yaml"

module CARPS

   # Resource manager
   class Resource

      # Takes as an argument a directory, within the users campaign directory
      def initialize rdir
         @dir = $CONFIG + "campaigns/#{rdir}"
      end

      # Create a new npc of a given type
      def new_npc type
         sheet_loc = @dir + "/npcs/" + type + ".yaml"
         begin
            return YAML::load File.read sheet_loc
         rescue
            warn "Could not create NPC: " + sheet_loc
            return nil
         end
      end

      # Put everyone in this room
      def players_in players, room_name
         room = load_room room_name
         if room
            players.each do |player|
               update_reporter player, room
            end
         end
      end

      # Load a room
      def load_room room
         room_loc = @dir + "/rooms/" + room + ".room"
         begin
            return Room.new room_loc
         rescue Exception => e
            warn "Could not load room: " + room_loc
            return nil
         end
      end

      # This player is in this room
      def player_in player, room_name
         room = load_room room_name
         if room
            update_reporter player, room
         end
      end

      # Register a reporter, update the reporter with changes
      def reporter= report
         @reporter = report
      end

      private

      # Update the reporter
      def update_reporter player, room
         @reporter.update_player player, room.describe
      end

   end

end
