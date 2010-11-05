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

require "carps/service"

require "carps/ui"

module CARPS

   module DM

      # Interface for creating new games
      class NewGameInterface < Interface

         # Create a new NewGameInterface from a continuation
         def initialize cont, manager, config, mailer
            super()
            @manager = manager
            @game_config = config
            @continuation = cont
            @mailer = mailer
            add_command :go, "Start the game."
            add_command :describe, "Describe the game."
            add_command :name, "Give the game a name.", "NAME"
            add_command :mod, "Choose the mod.\n#{options load_mods.keys}", "MOD"
            add_command :campaign, "Choose the campaign.", "CAMPAIGN"
         end

         protected

         # Set the campaign
         def campaign adventure
            @campaign = adventure
         end

         # Set the mod
         def mod user_mod
            if load_mods.include?(user_mod)
               @mod = user_mod
            else
               UI::put_error "No such mod is installed."
            end
         end

         # Describe the game
         def describe
            editor = Editor.load
            @description = editor.edit "# Enter description of game."
         end

         # Give the game a name
         def name nm
            @name = nm
         end

         # Start the game
         def go
            if @mod and @name and @description and @campaign
               puts "The game details are:"
               puts "Name: #{@name}"
               puts "Mod: #{@mod}"
               puts "Campaign: #{@campaign}"
               puts "Description: #{@description}"

               happy = UI::confirm "Are these details correct?"

               if happy
                  mods = load_mods
                  session_id = @manager.generate @name + @mod + @campaign
                  config = @game_config.new @name, @mod, @campaign, @description, session_id, @mailer.address
                  game = config.spawn
                  @continuation.call lambda {
                     game.start @mailer
                  }
               end
            else
               UI::put_error "You need to set the game options first."
            end

         end

      end

   end

end
