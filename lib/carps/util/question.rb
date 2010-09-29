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

# Ask a question, return a boolean
def confirm question
   h = HighLine.new
   resp = h.ask h.color("#{question}\n(Type anything beginning with y to accept)", :green)
   resp[0] == "y"
end

# Ask a question.  Get a string for an answer
def question msg
   h = HighLine.new
   h.ask h.color(msg, :green)
end
# Ask a question and don't echo what is typed.
def secret msg
   h = HighLine.new
   h.ask(h.color(msg, :green)) {|q| q.echo = "*"}
end
