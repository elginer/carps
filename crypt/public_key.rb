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

# Transmit public keys over email
class PublicKey < Message

   # Extend the protocol for public_keys 
   protoval "key"

   # Create a new handshake
   def initialize from, public_key, delayed_crypt=nil
      super from, delayed_crypt
      @public_key = public_key
   end

   # Parse from text
   def PublicKey.parse from, blob, delayed_crypt
      key, blob = find K.key, blob
      pkey = OpenSSL::PKey
      begin
         key = pkey::DSA.new key
         return [PublicKey.new(from, key, delayed_crypt), blob]
      rescue pkey::DSAError
         throw Expected.new "Public key"
      end
   end

   # Emit the handshake as text
   def emit
      V.key @public_key.to_pem
   end

   # Share the public key
   def key
      @public_key
   end

end 
