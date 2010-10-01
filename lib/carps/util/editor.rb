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
require "carps/util/error"

require "tempfile"

module CARPS

   # Expects a field called "launch_editor"
   class Editor < YamlConfig

      def Editor.default_file
         "editor.yaml"
      end

      def initialize editor
         @editor = editor
      end

      def parse_yaml config
         read_conf config, "launch_editor"
         @editor = editor
      end

      # Edit a string
      #
      # Not re-entrant
      def edit string
         begin
            file = Tempfile.new "carp_edit"
            path = file.path
            file.write string
            file.close
            string = edit_file path
            file = Tempfile.new "carp_edit"
            file.close!
            string
         rescue StandardError => e
            put_error e.to_s
            nil
         end
      end

      def edit_file filepath
         child = fork do
            exec @editor.gsub "%f", filepath
         end
         Object::Process.wait child

         if File.exists? filepath
            return File.read filepath
         else
            return ""
         end
      end

   end

end
