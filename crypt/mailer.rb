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


require "protocol/keyword"
require "util/log"
require "crypt/handshake"
require "digest/md5"

require "openssl"

# High level CARPS mail client supporting strong cryptographic message signing.  This prevents spoofing.
#
# You *must* have completed a handshake with a client before sending or receiving email from them.
class Mailer

   # Peers  
   class Peer

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
            text
         end
      end
   end

   # Extend protocol for signed data
   protoval "sig"
   # Extend protocol for sending random digests
   protoval "digest"
   # Extend protocol for sharing our address
   protoval "addr" 

   # The first parameter is the username.
   #
   # The second the mail receiver 
   #
   # The third is the mail sender.
   #
   # The fourth is a message parser
   def initialize user, receiver, sender, parser
      @addr = user 
      @receiver = receiver
      @sender = sender
      @peers = {}
      @parser = parser
      @private_key = get_keys
      @public_key = @private_key.public_key
   end

   # Give our address to interested parties
   def address
      @addr
   end

   # Get cryptographic keys
   #
   # If we can't find them, regenerate them
   def get_keys
      pkey = OpenSSL::PKey
      if File.exists? ".key"
         begin
            pem = File.read ".key"
            return pkey::DSA.new pem
         rescue
            log "Could not read .key file"
         end
      end
      keygen
   end 

   # Generate keys
   def keygen
      puts "Generating cryptographic keys.  This may take a minute."
      key = OpenSSL::PKey::DSA.generate 2048
      begin
         pri = File.new ".key", "w"
         pri.chmod 0600
         pri.write key.to_pem
         pri.close
      rescue
         log "Could not save cryptographic keys in the .key file", "They will be regenerated next time the application launches: an utter waste of time."
      end
      key
   end

   # Perform a handshake to authenticate with a peer
   def handshake addr
      puts "Making cryptographic handshake request to #{addr}"
      # Create a new peer
      peer = @peers[addr] = (Peer.new addr)
      # Send our key to the peer
      send addr, (Handshake.new @addr, @public_key)
      # Get the peer's key
      their_key = read :handshake, addr
      peer.your_key their_key.key
      # Send an okay message
      send addr, (HandshakeAccepted.new @addr)
      puts "Established spoof-proof communications with #{addr}"
   end

   # Wait for another peer to begin the handshake
   #
   # A British stereotype?
   def expect_handshake
      puts "Awaiting cryptographic handshake request..."
      # Get the email
      peer_key = read :handshake
      # Get the peer's address
      from = peer_key.from
      puts "Receiving handshake request from #{from}."
      # Create a new peer
      peer = @peers[from] = (Peer.new from)
      peer.your_key peer_key.key
      # Send our key to the peer
      send from, (Handshake.new @public_key)
      read :handshake_accepted, from
      puts "Established spoof-proof communications with #{addr}."
      from
   end

   # Send a message
   def send to, message
      text = message.emit
      # Sign the message
      digest = Digest::MD5.digest text 
      sig = @private_key.syssign digest
      mail = (V.addr @addr) + (V.sig sig) + (V.digest digest) + text + K.end
      @sender.send to, mail 
   end

   # Receive a message
   def read type, must_be_from = nil
      # Loop until we get a message of the correct type
      while true
         mail = @receiver.read
         unless mail
            next
         end
         who = nil
         blob = nil
         begin
            # Find who sent the message
            who, blob = find K.addr, mail
         rescue Expected
            log "Mail message did not contain sender", blob 
            continue
         end
         # Abort if incorrect address
         if must_be_from and must_be_from != who
            next
         end

         # Find the peer who sent the message
         unless(peer = @peers[who])
            log "Mail received from unregistered peer #{who}", blob
            next
         end
        
         # Strip the last end marker and any text after it
         blob = clean_end blob
         # The peer will verify the signature at the start of the text and pass on the rest
         if(blob = peer.verify blob)
            # Parse a message
            msg = @parser.parse who, blob
            # Ding!
            puts "\a"
            if msg != nil and msg.type == type
               return msg
            end
         end
      end
   end

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

end
