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

require "mod/mod"
require "mod/client_turn"

require "util/error"

# Player mod
class PlayerMod < Mod

   def initialize pmailer
      @mailer = pmailer
   end

   # Check mail
   def check
      turn = @mailer.check ClientTurn
      if turn
         @answers = turn.take
      else
         puts "No new mail."
      end
   end

   # Send answers to dungeon master
   def next_turn
      if @answers
         @mailer.send @answers
      else
         put_error "Nothing to send."
      end
   end

end
