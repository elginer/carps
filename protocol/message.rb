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


require "util/warn"

# Parse, choosing from a number of alternative messages, return the first one that suceeds
def choose from, messages, blob
   messages.each do |message|
      begin
         result, text = message.parse from, blob
         return [result, text] 
      rescue Expected
      end
   end
   raise Expected
end

# Parse a message from a block of unformatted text
class MessageParser

   # Create a new parser from a list of choices
   def initialize choices
      @choices = choices
   end

   # Parse the text into a message 
   def parse from, text
      input = text
      begin
         msg, blob = choose from, @choices, text 
         return msg
      rescue Expected
         warn "An invalid email was received:", input
         return nil
      end
   end
end

# A message
class Message

   # Save who we're from
   def initialize from
      @from = from
   end

   # Who we're from
   def from
      @from
   end

   # Parse.
   #
   # The first parameter is the email address this text is from
   # The second parameter is the text itself.
   def parse from, text
      nil
   end

end
