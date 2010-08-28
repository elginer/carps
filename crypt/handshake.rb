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
require "protocol/keyword"

require "openssl"

# A cryptographic handshake request
class Handshake < Message

   # Extend the protocol for cryptographic handshakes
   protoval "handshake"

   # Create a new handshake
   def initialize from, public_key
      super from
      @public_key = public_key
   end

   # Parse from text
   def Handshake.parse from, blob
      key, blob = find K.handshake, blob
      pkey = OpenSSL::PKey
      begin
         key = pkey::DSA.new key
         return [Handshake.new(from, key), blob]
      rescue pkey::DSAError
         throw Expected.new "Public key"
      end
   end

   # Emit the handshake as text
   def emit
      V.handshake @public_key.to_pem
   end

   # Share the public key
   def key
      @public_key
   end

end 
