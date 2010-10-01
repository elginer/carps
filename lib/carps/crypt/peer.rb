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

require "carps/util/warn"
require "carps/protocol/keyword"

require "openssl"

require "yaml"

module CARPS

   # Clean the end of an email
   #
   # Strip the last end marker and any text after it 
   def clean_end blob
      rb = blob.reverse
      before, after = rb.split K.end.reverse, 2
      if after
         return after.reverse
      end
      nil
   end

   # Fetch security information from an email
   def security_info blob
      blob = clean_end blob
      sig = nil   
      begin
         sig, blob = find K.sig, blob
      rescue
         warn "Message signature was malformed", blob
         return nil
      end
      # If the digest is the hash of the message and the signature matches the digest then all is well
      dig = Digest::MD5.digest blob
      [[sig, dig], blob]
   end

   # Peers  
   class Peer < UserConfig

      # Extend protocol for signed data
      protoval :sig 

      # Create a new peer
      def initialize addr
         @addr = addr
      end

      def addr
         @addr
      end

      # Tell this peer its key
      def your_key key
         @peer_key = key
      end

      # Perform a verification on an email
      def verify mail
         sig, dig = mail.crypt 
         pass = @peer_key.sysverify dig, sig
         if pass
            return true
         else
            warn "Someone has attempted to spoof an email from #{mail.from}", mail.to_s 
            return false
         end
      end

      def save
         save_file ".peers/" + @addr
      end

      protected

      # Emit this peer as a yaml document
      def emit
         {"addr" => @addr, "key" => @peer_key.to_pem}
      end

      def parse_yaml conf
         key_pem = read_conf conf, "key"
         addr = read_conf conf, "addr"

         key = OpenSSL::PKey::DSA.new key_pem
         [key, addr]
      end

      def load_resources key, addr
         p = Peer.new addr
         p.your_key key
         p
      end

   end

end
