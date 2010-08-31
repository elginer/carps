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

def rainbow msg
   msga = msg.split //
   cols = [:red, :green, :yellow, :blue, :magenta]
   cols_replicate = msga.length / cols.length
   extra = msga.length % cols.length
   if extra
      cols_replicate += 1
   end
   cols = Array.new(cols_replicate, cols).flatten
   msga = msga.zip cols
   h = HighLine.new
   msga = msga.map do |char, col|
      h.color char, col
   end
   msga.join
end

puts rainbow "Welcome to Fruit, version 0.0.1!"
STDIN.gets
