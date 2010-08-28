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

# Peers  
class Peer

   # Extend protocol for signed data
   protoval :sig 
   # Extend protocol for sending random digests
   protoval :digest 

   # Create a new peer
   def initialize addr
      @addr = addr
   end

   # Tell this peer its key
   def your_key key
      @peer_key = key
   end

   # Verify text was sent by this peer
   def verify blob
      if @peer_key
         sig = nil   
         dig = nil
         blob = nil
         begin
         sig, blob = find K.sig, blob
         dig, blob = find K.digest, blob
         rescue
            log "Message signature was malformed", blob
            return nil
         end
         # If the digest is the hash of the message and the signature matches the digest then all is well
         if (Digest::MD5.digest blob) and (@peer_key.sysverify dig, sig)
            return blob
         else
            log "Someone has attempted to spoof an email from #{@addr}", blob
            return nil
         end
      else
         # We can't tell...
         blob
      end
   end
end

