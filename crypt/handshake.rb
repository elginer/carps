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
