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

require "protocol/message"

require "util/highlight"

require "highline"

require "yaml"

# A series of answers to questions asked by the DM.
class Answers < Message

   # Extend the protocol
   protoval :answers

   # The answers hash gives the initial answers
   def initialize answers_hash = {}
      @answers = answers_hash
   end

   # Parse
   def Answers.parse from, blob, delayed_crypt
      yaml, blob = find K.answers, blob
      answers = YAML::load yaml
      [Answers.new(answers), blob]
   end

   # Emit
   def emit
      V.answers @answers.to_yaml
   end

   # Set an answer to a question
   def answer question, response
      @answers[question] = response
   end

   # Display answers
   def display
      if @answers.empty?
         highlight "#{from} did not return any answers."
      else
         highlight "#{from}'s answers:"
         h = HighLine.new
         @answers.each do |que, ans|
            puts ""
            puts h.color(que, :green)
            ans.each_line do |ln|
               puts ">  " + ln
            end
         end
         puts ""
         highlight "End of #{from}'s answers\n"
      end
   end
end
