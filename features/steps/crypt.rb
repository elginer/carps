# Test cryptography mechanism

require "crypt/mailer"
require "crypt/mailbox"
require "crypt/default_messages"

require "protocol/message"

require "util/init"

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

Given /^two peers, Alice and Bob$/ do
   receive_alice = TestReceiver.new
   receive_bob = TestReceiver.new
   send_bob = TestSender.new
   send_bob.send_to receive_alice
   send_alice = TestSender.new
   send_alice.send_to receive_bob
   init "test/server"
   $alice_box = Mailbox.new send_bob, receive_bob, MessageParser.new(default_messages)
   $alice = Mailer.new "alice", $alice_box
   init "test/client"
   $bob_box = Mailbox.new send_alice, receive_alice, MessageParser.new(default_messages)
   $bob = Mailer.new "bob", $bob_box
   $bob_address = "bob" 
end

Then /^Alice initiates a handshake request and Bob accepts$/ do
   Thread.fork do
      bchild = $bob.expect_handshake
      bchild.join
      $bob_box.shutdown
   end
   child = $alice.handshake $bob_address
   child.join
   $alice_box.shutdown
end
