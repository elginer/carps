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
require "carps/util/process"

module CARPS

   class ConfInterface < Interface

      def initialize
         super
         add_command "test", "Test that your settings are correct."
         add_command "done", "Proceed to the next step."
      end

      protected

      def repl
         puts "STEP: #{description}"
         super
      end

   end

   class EditorConf < ConfInterface

      def initialize
         super
         add_command "editor", "Specify a command used to edit a file.\n\tUse %f in place of the filepath.\n\tEnsure that the editor does not detach itself from the foreground.\n\t\tExample: gvim --nofork %f", "COMMAND"
      end

      def editor command
         @editor = command
      end

      def test
      end

      def description
         "Choose an appropriate text editor for editing character sheets, etc."
      end

   end

end
