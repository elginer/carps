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

# A cryptographic handshake request
class Handshake < Message

   # Extend the protocol for cryptographic handshakes
   protoval "handshake"

   # Create a new handshake
   def initialize from, public_key
      @from = from
      @public_key = public_key
   end

   # Parse from text
   def parse from, blob
      forget, blob = find K.handshake, blob
      [Handshake.new(from, key), blob]
   end

   # Emit the handshake as text
   def emit
      V.public_key @public_key
   end

end 
