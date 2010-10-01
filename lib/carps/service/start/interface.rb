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

require "carps/service/interface"

require "carps/util/highlight"
require "carps/util/error"

require "continuation"

module CARPS

   # Interface to start games
   class StartGameInterface < QuitInterface

      include ControlInterface

      # Start interface
      def StartGameInterface.start_game_interface mailer, config
         choice = callcc do |continuation|
            interface = self.new continuation, mailer, config
            interface.run
         end
         choice.call
      end

      def initialize continuation, mailer, game_config
         @mailer = mailer
         @game_config = game_config
         @continuation = continuation
         super()
         add_command "games", "List existing games."
         add_command "load", "Load an existing game.", "NAME"
      end

      protected

      def games
         dir = $CONFIG + "/games"
         fs = files dir
         fs.each do |f|
            name = File.basename(f, ".yaml")
            puts ""
            highlight "Name: " + name
            g = @game_config.load "games/" + File.basename(f)
            g.display
         end

      end

      def load name
         filename = "games/" + name + ".yaml"
         config = nil
         begin
            config = @game_config.load filename
         rescue StandardError => e
            put_error e.to_s
         end
         if config
            game = config.spawn @mailer
            @continuation.call lambda {game.resume}
         end
      end

   end

end
