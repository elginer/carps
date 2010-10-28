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

require "carps/ui/error"

require "carps/test"

require "tempfile"

module CARPS

   # Expects a field called "launch_editor"
   class Editor < SystemConfig

      def Editor.filepath
         "editor.yaml"
      end

      def initialize editor, wait_for_confirm = false
         @editor = editor
         @wait_confirm = wait_for_confirm
      end

      def parse_yaml config
         @editor = read_conf config, "launch_editor"
         @wait_confirm = read_conf config, "wait"
      end

      # Edit a string
      #
      # Not re-entrant
      def edit msg
         begin
            file = Tempfile.new "carp_edit"
            path = file.path
            file.write "# Lines starting with # will be ignored.\n" + msg 
            file.close
            contents = edit_file path
            lines = contents.split /\n/
               lines.reject! do |line|
               line[0] == '#'
               end
            lines.join "\n"
         rescue StandardError => e
            UI::put_error e.to_s
            nil
         end
      end

      protected

      def edit_file filepath
         child = fork do
            exec @editor.gsub "%f", filepath
         end
         Object::Process.wait child

         if @wait_confirm
            UI::question "Press enter when you are done editing."
         end

         if File.exists? filepath
            return File.read filepath
         else
            return ""
         end
      end


      # Emit as hash
      def emit
         {
            "launch_editor" => @editor,
            "wait" => @wait_confirm
         }
      end

   end

   module Test


      # Testing for editor
      module Editor

         def load_fail
            test_failed "The editor did not load the file correctly."
         end

         def save_fail
            test_failed "The editor did not save the file correctly."
         end

      end

      # Test the editor
      def Test::editor editor
         puts "The editor should launch, then you should edit this paragraph:"
         before = "What ho Jeeves!"
         puts before
         puts "Once you are done editing, save the file and close the editor."
         if after = editor.edit(before)
            if after == before
               Test::multi_fail "Your editor is detaching itself into the background.", "You did not edit the paragraph.  Do so!", "The editor did not save the file correctly.", "The editor did not load the file correctly."
            else
               before_good = UI::confirm "Before you starting editing, did the editor display this text?\n#{before}"
               if before_good
                  after_good = UI::confirm "Did you change that to this?\n#{after}"
                  if after_good
                     return true
                  else
                     Editor::save_fail
                  end
               else
                  Editor::load_fail
               end
            end
         else
            Editor::save_fail
         end

      end
   end

end
