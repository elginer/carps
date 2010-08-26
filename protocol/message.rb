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


require "util/log.rb"
require "service/game.rb"

require "crypt/handshake.rb"

# Parse, choosing from a number of alternative messages, return the first one that suceeds
def choose from, messages, blob
   messages.each do |message|
      begin
         result, blob = message.parse from, blob
         return [result, blob] 
      rescue Expected
      end
   end
   throw Expected.new messages 
end

# Parse a message from a block of unformatted text
# Subclasses must create a method called choices which is a list of classes supporting a parse method 
class MessageParser

   def system_choices
      [Handshake]
   end

   # Parse the text into a message 
   def parse from, text
      input = text
      begin
         msg, blob = choose from, (choices + system_choices), text 
         return msg
      rescue Expected
         log "An invalid email was received:", input
         return nil
      end
   end
end


# Receive messages for the client
class ClientParser < MessageParser
   def choices
      [Invite]
   end
end

# Receive messages for the server
class ServerParser < MessageParser
   def choices
      []
   end
end

# A message
class Message
   # We don't know what type the message will be when we ask for it, so we'll have to check
   def type
      nil
   end

   # Parse.
   #
   # The first parameter is the email address this text is from
   # The second parameter is the text itself.
   def parse from, text
      nil
   end

end
