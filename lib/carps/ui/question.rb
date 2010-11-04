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

require "highline"

require "carps/ui/colour"

module CARPS

   module UI

      # Because we mess with the modes, and we're meant to run in a safe environment, need to hack highline.
      HighLine::SystemExtensions.module_eval do
         def restore_mode
            @state.untaint
            system "stty #{@state}"
         end
      end

      # Ask a question, return a boolean
      def UI::confirm question
         h = HighLine.new
         resp = h.ask h.color("#{question}\n(Type anything beginning with y to accept)", :green)
         resp[0] == "y"
      end

      # Ask a question.  Get a string for an answer
      #
      # Calls untaint on the answer
      def UI::question msg
         h = HighLine.new
         res = h.ask h.color(msg, :green)
         # Trust the user
         res.untaint
      end

      # Ask a question and don't echo what is typed.
      #
      # Calls untaint on the password
      def UI::secret msg
         h = HighLine.new
         ooh = h.ask(h.color(msg, :green)) {|q| q.echo = "*"}
         h.untaint
         ooh
      end

   end

end
