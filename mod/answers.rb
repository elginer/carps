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
require "yaml"

require "highline"

# A series of answers to questions asked by the DM.
class Answers

   # Extend the protocol
   protoval :answers

   # The answers hash gives the initial answers
   def initialize from, delayed_crypt = nil, answers_hash = {}
      super from, delayed_crypt
      @answers = answers_hash
   end

   # Parse
   def Answers.parse from, blob, delayed_crypt
      yaml, blob = find K.answers, blob
      answers = YAML::load yaml
      [Answers.new(from, delayed_crypt, answers), blob]
   end

   # Emit
   def emit
      V.answers @answers.to_yaml
   end

   # Set an answer to a question
   def answer type, response
      @answers[type] = response
   end

   # Get the answer to a question
   def read type
      @answers[type]
   end

   # Display answers
   def display
      h = HighLine.new
      puts h.color("#{from}'s answers:", :blue)
      @answers.each do |que, ans|
         puts h.color(que, :green)
         ans.each_line do |ln|
            puts ">  " + ln
         end
         puts "\n"
      end
      puts h.color("End of #{from}'s answers", :blue)
   end
end
