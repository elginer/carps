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

require "highline"

class ClientTurn < Message

   # Extend the protocol
   protoword :client_turn

   # Create a client turn
   def initialize addr, status, questions, delayed_crypt = nil
      super addr, delayed_crypt
      @status = status
      @questions = questions
   end

   # Parse
   def ClientTurn.parse from, blob, delayed_crypt
      forget, blob = find K.client_turn blob
      status, blob = StatusReport.parse from, blob, delayed_crypt
      more = true
      questions = []
      while more
         begin
            que, blob = Question.parse from, blob, delayed_crypt
            questions.push que
         rescue Expected
            more = false
         end
      end
      [ClientTurn.new(from, status, questions, delayed_crypt), blob] 
   end

   # Emit
   def emit
      question_text = (@questions.map {|q| q.emit}).join
      K.client_turn + @status.emit + question_text
   end

   # Take the turn
   def take mailer
      h = HighLine.new
      puts h.color("It is your turn:", :blue)
      puts "\a"
      @status.display
      answers = Answers.new from
      @questions.each do |q|
         q.ask answers
      end
      mailer.send from, answers
   end

end
