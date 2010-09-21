# Test cryptography mechanism

require "crypt/mailer"
require "crypt/mailbox"
require "crypt/default_messages"

require "protocol/message"

require "util/init"

require "fileutils"

class EvilMessage < Message

   def emit
      "EVIL"
   end

   def EvilMessage.parse blob
      if blob.match(/EVIL/)
         return EvilMessage.new
      else
         return nil
      end
   end

end

class TwistedMailbox < Mailbox
   def forget person
      @peers.delete person
   end
end

class TwistedMailer < Mailer
   # Send an evil message.  The recipent should drop this.
   def evil to, message
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

   def forget person
      @mailbox.forget person
   end
end

class TestSender

   def send to, message
      @receiver.receive message
   end

   def send_to receiver
      @receiver = receiver
   end

end

class TestReceiver

   def receive message
      @message = message
   end

   def read
      until @message
         sleep 1
      end
      message = @message
      @message = nil
      [message]
   end

end

def delete_key person
   path = $CONFIG + "/.peers/" + person
   if File.exists?(path)
      puts "Deleting key " + path
      FileUtils.rm path
   else
      puts "Could not delete key " + path
   end
end

Given /^two peers, Alice and Bob$/ do
   receive_alice = TestReceiver.new
   receive_bob = TestReceiver.new
   send_bob = TestSender.new
   send_bob.send_to receive_alice
   send_alice = TestSender.new
   send_alice.send_to receive_bob
   
   $alice_address = "alice"
   $bob_address = "bob"

   # Alice's stuff
   init "test/server"
   delete_key "bob"
   $alice_box = Mailbox.new send_bob, receive_bob, MessageParser.new(default_messages)
   $alice = TwistedMailer.new $alice_address, $alice_box

   # Bob's stuff
   init "test/client"
   delete_key "alice"
   $bob_box = TwistedMailbox.new send_alice, receive_alice, MessageParser.new(default_messages.push EvilMessage)
   $bob = TwistedMailer.new $bob_address, $bob_box
end

Then /^Alice initiates a handshake request and Bob accepts$/ do
   Thread.fork do
      bchild = $bob.expect_handshake
      if bchild
         bchild.join
      end
   end
   child = $alice.handshake $bob_address
   if child
      child.join
   end
end

Then /^a hacker pretending to be Alice sends a nefarious message to Bob$/ do
   $alice.evil $bob_address, EvilMessage.new
   t = Thread.fork do
      $bob.read EvilMessage
   end
   sleep 5
   t.kill
end

Then /^Alice and Bob's mailers are shut down$/ do
   $alice.shutdown
   $bob.shutdown
end

Then /^a spoofer pretending to be Bob tries to make a handshake with Alice$/ do
   $bob.forget $alice_address 
   Thread.fork do
      bchild = $bob.handshake $alice_address
      sleep 5
      bchild.kill
   end
   child = $alice.expect_handshake
   if child
      child.join
   end
end
