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

# A status report, followed by a list of questions

require "protocol/message"

require "mod/answers"
require "mod/status_report"

class ClientTurn < Message

   # Extend the protocol
   protoword :client_turn

   # Create a client turn
   def initialize status, questions
      @status = status
      @questions = questions
   end

   # Parse
   def ClientTurn.parse blob
      forget, blob = find K.client_turn blob
      status, blob = StatusReport.parse blob
      more = true
      questions = []
      while more
         begin
            que, blob = Question.parse blob
            questions.push que
         rescue Expected
            more = false
         end
      end
      [ClientTurn.new(status, questions), blob] 
   end

   # Emit
   def emit
      question_text = (@questions.map {|q| q.emit}).join
      K.client_turn + @status.emit + question_text
   end

   # Preview the turn
   def preview
      @status.display
      @questions.each do |q|
         q.preview
      end
   end

   # Take the turn, return list of answers
   def take
      @status.display
      answers = Answers.new
      @questions.each do |q|
         q.ask answers
      end
      answers
   end

end
