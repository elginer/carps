require "protocol/keyword"
require "util/log"
require "crypt/handshake"

require "openssl"

# High level mail client supporting strong crypto signing through dsa.
#
# You *must* have completed a handshake with a client before sending or receiving email from them
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
            if @peer_key.sysverify dig, sig
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
      @private_key = keygen
      @public_key = private_key.public_key
      # We use these to create the digest
      @randoms = ("!".."~").to_a
   end

   # Generate keys
   def keygen
      OpenSSL::PKey::DSA.generate 2048
   end

   # Perform a handshake to authenticate with a peer
   def handshake addr
      # Create a new peer
      peer = @peers[addr] = Peer.new addr
      # Send our key to the peer
      send addr, Handshake.new @addr, @public_key
      # Get the peer's key
      their_key = read :handshake, addr
      peer.your_key their_key.key
   end

   # Wait for another peer to begin the handshake
   #
   # A British stereotype?
   def expect_handshake
      # Get the email
      peer_key = read :handshake
      # Create a new peer
      peer = @peers[from = peer_key.from] = Peer.new from
      peer.your_key peer_key.key
      # Send our key to the peer
      send from, Handshake.new @public_key 
   end

   # Send a message
   def send to, message
      digest = ((0..19).map {|n| rs[rand(rs.size)]}).join
      sig = @private_key.syssign digest 
      @sender.send to, (V.addr @addr) + (V.sig sig) + (V.digest digest) + message.emit
   end

   # Receive a message
   def read type, must_be_from = nil
      # Loop until we get a message of the correct type
      while true
         mail = @receiver.read
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
         unless peer = @peers[who]
            log "Mail received from unregistered peer #{who}", blob
            next
         end
         
         # The peer will verify the signature at the start of the text and pass on the rest
         if blob = peer.verify blob
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

end
