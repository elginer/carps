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


require "carps/protocol/keyword"

require "carps/ui/warn"
require "carps/ui/question"

require "carps/util/process"
require "carps/util/files"

require "carps/crypt/handshake"
require "carps/crypt/public_key"
require "carps/crypt/accept_handshake"
require "carps/crypt/peer"

require "digest/md5"

require "openssl"

module CARPS

   # High level CARPS mail client supporting strong cryptographic message signing.
   #
   # It has knowledge of our own public and private key.  Its big responsibility is turning Messages into Strings and signing them.
   class Mailer

      # Extend protocol for sharing our address
      protoval :addr  

      # The first parameter is the email address
      #
      # The second the Mailbox.
      def initialize address, mailbox
         @addr = address
         @mailbox = mailbox
         @private_key = get_keys
         @public_key = @private_key.public_key
         # Load the old peers
         load_peers
      end

      # Perform a handshake to authenticate with a peer
      def handshake to
         if @mailbox.peer? to
            puts "No need for handshake: " + to + " is already a known peer."
         else
            puts "Offering cryptographic handshake to #{to}"
            # Create a new peer
            peer = Peer.new to
            @mailbox.add_peer peer
            # Request a handshake 
            send to, Handshake.new
            # Get the peer's key
            their_key = @mailbox.insecure_read PublicKey, to
            peer.your_key their_key.key
            peer.save 
            # Send our key
            send to, PublicKey.new(@public_key)
            # Receive an okay message
            read AcceptHandshake, to
            puts "Established spoof-proof communications with #{to}"
         end
      end

      # Shutdown the mailer
      def shutdown
         @mailbox.shutdown
      end

      # Check for handshakes
      def check_handshake
         @mailbox.insecure_check Handshake
      end

      # Respond to a handshake request
      def handle_handshake handshake
         # Get the peer's address
         from = handshake.from
         puts "Receiving handshake request from #{from}."
         if @mailbox.peer? from
            UI::warn "Handshake request from #{from} has been dropped because #{from} is already a known peer",  "Possible spoofing attack."
         else
            # See if the user accepts the handshake.
            accept = accept_handshake? from
            if accept
               # Send our key to the peer
               send from, PublicKey.new(@public_key)
               # Get their key
               peer_key = @mailbox.insecure_read PublicKey, from
               # Create a new peer
               peer = Peer.new from
               @mailbox.add_peer peer
               peer.your_key peer_key.key
               peer.save
               # Send an okay message
               send from, AcceptHandshake.new
               puts "Established spoof-proof communications with #{from}."
            end
         end
      end

      # Give our address to interested parties
      def address
         @addr
      end

      # Send a message
      def send to, message
         text = message.emit
         # Sign the message
         digest = Digest::MD5.digest text
         sig = @private_key.syssign digest
         mail = (V.addr @addr) + (V.sig sig) + text + K.end
         @mailbox.send to, mail
         puts "#{message.class} sent to " + to
      end

      # Receive a message.  Block until it is here.
      def read type, must_be_from=nil
         @mailbox.read type, must_be_from
      end

      # Check for a message.  Don't block!  Return nil if nothing is available.
      def check type, must_be_from=nil
         @mailbox.check type, must_be_from
      end

      protected

      # Ask the user if they accept the handshake.
      #
      # Refactored out for tinkering and automated testing.
      def accept_handshake? from
         UI::confirm "Accept handshake from #{from}?"
      end


      private

      # Get cryptographic keys
      #
      # If we can't find them, regenerate them
      def get_keys
         pkey = OpenSSL::PKey
         if File.exists? keyfile 
            begin
               pem = File.read keyfile
               return pkey::DSA.new pem
            rescue
            end
         end
         UI::warn "Could not read cryptographic key from #{keyfile}"
         return keygen
      end 

      # The key file
      def keyfile
         keyfile = $CONFIG + ".key"
      end

      # Generate keys
      def keygen
         puts "Generating cryptographic keys.  This may take a minute."
         key = OpenSSL::PKey::DSA.generate 2048
         begin
            pri = File.new keyfile, "w"
            pri.chmod 0600
            pri.write key.to_pem
            pri.close
         rescue
            UI::warn "Could not save cryptographic keys in #{keyfile}", "They will be regenerated next time CARPS is run."
         end
         key
      end


      # Peer directory
      def peer_dir
         # Yes, this is strange.  It's to cope with needed to have two mailers at once for testing, which never would normally happen.
         # In other words, global variables are bad and Haskell is right.
         unless @peer_dir
            @peer_dir = $CONFIG + "/.peers/"
         end
         @peer_dir
      end

      # Load previous peers
      def load_peers
         peer_file_names = files peer_dir
         peer_file_names.each do |p|
            load_peer p
         end
      end

      # Load a peer
      def load_peer peer_file_name
         peer = Peer.load ".peers/" + File.basename(peer_file_name)
         @mailbox.add_peer peer
      end

   end
end
