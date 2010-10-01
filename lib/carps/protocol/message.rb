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

require "carps/protocol/keyword"

require "carps/util/warn"

require "drb"

module CARPS

   # Parse a message from a block of unformatted text
   class MessageParser

      # Create a new parser from a list of choices
      def initialize choices
         @choices = choices
      end

      # Parse, choosing from a number of alternative messages, return the first one that suceeds
      def choose_parser blob 
         @choices.each do |message|
            begin
               result, text = message.parse blob
               return [result, text] 
            rescue Expected
            end
         end
         raise Expected
      end

      # Parse the text into a message 
      def parse text
         input = text
         begin
            msg, blob = choose_parser text
            return msg
         rescue Expected
            warn "An invalid email was received:", input
            return nil
         end
      end
   end

   # A message
   class Message

      # Set cryptography information
      def crypt= sig
         @delayed_crypt = sig
      end

      # Cryptography information
      def crypt
         @delayed_crypt
      end

      # set who we're from
      def from= addr
         @from = addr
      end

      # Who we're from
      def from
         @from
      end

      # Parse.
      #
      # The first parameter is the email address this text is from
      # The second parameter is the text itself.
      def parse text
         nil
      end

   end

end
