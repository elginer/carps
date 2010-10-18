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

require "carps/protocol"

require "carps/mod"

require "carps/ui"

module CARPS

   # A question sent by the server, to be asked of the player.
   #
   # Interacts with Answers class
   class Question < Message

      # Extend the protocol
      protoval :question

      # Create a question
      def initialize question
         @text = question
      end

      # Parse from the void
      def Question.parse blob
         question, blob = find K.question, blob
         [Question.new(question), blob]
      end

      # Emit
      def emit
         V.question @text 
      end

      # Ask the question, store the answer in the answers object
      def ask answers
         response = UI::question @text
         answers.answer @text, response
      end

      # Preview the question
      def preview
         puts "Question: " + @text
      end

   end

end
