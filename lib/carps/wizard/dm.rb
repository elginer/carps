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

require "carps/wizard/steps"

require "carps/wizard/wizard"

module CARPS

   module DM

      # A wizard for configuring the Dungeon Master 
      class Wizard < CARPS::Wizard

         def initialize
            files = ["../mods.yaml", "email.yaml", "process.yaml", "editor.yaml"]
            dirs = ["games", ".peers", "campaigns"]         
            super files, dirs
            set_steps EditorConf.new, ProcessConf.new, EmailConf.new
         end

      end

   end

end

