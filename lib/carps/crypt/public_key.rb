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

require "carps/protocol/message"
require "carps/protocol/keyword"

require "openssl"

module CARPS

   # Transmit public keys over email
   class PublicKey < Message

      # Extend the protocol for public_keys 
      protoval "key"

      # Create a new handshake
      def initialize public_key
         @public_key = public_key
      end

      # Parse from text
      def PublicKey.parse blob
         key, blob = find K.key, blob
         pkey = OpenSSL::PKey
         begin
            key = pkey::DSA.new key
            return [PublicKey.new(key), blob]
         rescue pkey::DSAError
            raise Expected, "Public key"
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

end
