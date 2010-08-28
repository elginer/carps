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
require "crypt/accept_handshake"
require "crypt/peer"
require "crypt/mailbox"

require "digest/md5"

require "openssl"

# High level CARPS mail client supporting strong cryptographic message signing.
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
      @session = nil
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

   # Send a message
   def send to, message
      text = message.emit
      # Sign the message
      digest = Digest::MD5.digest text 
      sig = @private_key.syssign digest
      session = ""
      if @session
         session = V.session @session.to_s
      end
      mail = (V.addr @addr) + session + (V.sig sig) + (V.digest digest) + text + K.end
      @mailbox.send to, mail
      puts "Message sent to " + to
   end

   # Receive a message
   def read type, must_be_from = nil
      @mailbox.read type, must_be_from
   end

end

# Mailer for the server
class ServerMailer < Mailer

   def initialize address, receiver, sender, parser
      super address, receiver, sender, parser
      @session = read_session
      @mailbox.set_session @session
   end

   # Read the session from the session file
   def read_session
      begin
         session = File.read(".session").to_i
         session = session + 1
         File.write ".session", new_session
         return new_session
      rescue
         begin
            sessionf = File.new ".session", "w"
            sessionf.write "42"
            sessionf.close
         rescue
            log "Session file .session could not be written.  CARPS might behave strangely."
         end
         return 42
      end
   end

   # Perform a handshake to authenticate with a peer
   def handshake to
      puts "Making cryptographic handshake request to #{to}"
      # Create a new peer
      peer = Peer.new to
      @mailbox.add_peer @addr, peer
      # Send our key to the peer
      send to, Handshake.new(@addr, @public_key)
      # Get the peer's key
      their_key = read Handshake, to
      peer.your_key their_key.key
      # Send our session
      send to, SessionHandshake.new(@addr, @session)
      # Receive an okay message
      read AcceptHandshake, to
      @mailbox.secure
      puts "Established spoof-proof communications with #{addr}"
   end
end

# Mailer for the client
class ClientMailer < Mailer
   # Wait the someone to begin the handshake
   #
   # A British stereotype?
   def expect_handshake
      puts "Awaiting cryptographic handshake request..."
      # Get the email
      peer_key = read Handshake 
      # Get the peer's address
      from = peer_key.from
      puts "Receiving handshake request from #{from}."
      # Create a new peer
      peer = Peer.new from
      @mailbox.add_peer @addr, peer
      peer.your_key peer_key.key
      # Send our key to the peer
      send from, (Handshake.new @addr, @public_key)
      # Receive their session
      @session = read(SessionHandshake, from).session
      @mailbox.set_session @session 
      # Send an okay message
      send from, (AcceptHandshake.new @addr)
      @mailbox.secure
      puts "Established spoof-proof communications with #{addr}."
      from
   end
end
