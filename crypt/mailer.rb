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

require "util/warn"
require "util/question"
require "util/process"

require "crypt/handshake"
require "crypt/public_key"
require "crypt/accept_handshake"
require "crypt/peer"
require "crypt/mailbox"

require "digest/md5"

require "openssl"

require "highline"

init_threading

# High level CARPS mail client supporting strong cryptographic message signing.
#
# It has knowledge of our own public and private key
class Mailer

   # Extend protocol for sharing our address
   protoval :addr  

   # The first parameter is the username.
   #
   # The second the mail receiver 
   #
   # The third is the mail sender.
   #
   # The fourth is a message parser
   def initialize address, receiver, sender, parser
      @addr = address 
      @mailbox = Mailbox.new sender, receiver, parser
      @private_key = get_keys
      @public_key = @private_key.public_key
      Thread.fork do
         loop do 
            expect_handshake
         end
      end
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
            warn "Could not read .key file"
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
         warn "Could not save cryptographic keys in the .key file", "They will be regenerated next time CARPS is run."
      end
      key
   end

   # Send a message
   def send to, message
      message.from = address
      text = message.emit
      # Sign the message
      digest = Digest::MD5.digest text
      sig = @private_key.syssign digest
      mail = (V.addr @addr) + (V.sig sig) + text + K.end
      @mailbox.send to, mail
      puts "#{message.class} sent to " + to
   end

   # Send an evil message for testing.  The recipent should drop this.
   def evil to, message
      message.from = address
      text = message.emit
      # Sign the message
      digest = Digest::MD5.digest text
      puts "sent digest (as part of an evil scheme): " + digest
      new_key = OpenSSL::PKey::DSA.new 2048
      sig = new_key.syssign digest
      mail = (V.addr @addr) + (V.sig sig) + text + K.end
      @mailbox.send to, mail
      puts "Message sent to " + to
   end

   # Receive a message
   def read type, must_be_from=nil
      @mailbox.read type, must_be_from
   end

   # Perform a handshake to authenticate with a peer
   def handshake to
      Thread.fork do
         puts "Offering cryptographic handshake to #{to}"
         # Create a new peer
         peer = Peer.new to
         @mailbox.add_peer to, peer
         # Request a handshake 
         send to, Handshake.new
         # Get the peer's key
         their_key = @mailbox.insecure_read PublicKey, to
         peer.your_key their_key.key
         # Send our key
         send to, PublicKey.new(@public_key)
         # Receive an okay message
         read AcceptHandshake, to
         puts "Established spoof-proof communications with #{to}"
      end
   end

   # Wait the someone to begin the handshake
   #
   # A British stereotype?
   def expect_handshake
      # Get the handshake 
      handshake = @mailbox.insecure_read Handshake
      # Get the peer's address
      from = handshake.from
      puts "Receiving handshake request from #{from}."
      if @mailbox.peer? from
         warn "#{from} is already a registered peer.  This could be an attempt to conduct a spoofing attack."
      end
      # See if the user accepts the handshake.
      accept = confirm "Accept handshake from #{from}?"
      Thread.fork do
         if accept
            # Send our key to the peer
            send from, PublicKey.new(@public_key)
            # Get their key
            peer_key = @mailbox.insecure_read PublicKey, from
            # Create a new peer
            peer = Peer.new from
            @mailbox.add_peer from, peer
            peer.your_key peer_key.key
            # Send an okay message
            send from, AcceptHandshake.new
            puts "Established spoof-proof communications with #{from}."
         end
      end
   end
end
