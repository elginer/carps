# Test cryptography mechanism

require "carps/crypt/mailer"
require "carps/crypt/mailbox"
require "carps/crypt/default_messages"

require "carps/protocol/message"

require "carps/util/init"

require "carps/service/session"

require "fileutils"

require "thread"

class EvilMessage < Message

   def emit
      "EVIL"
   end

   def EvilMessage.parse blob
      if blob.match(/EVIL/)
         return [EvilMessage.new, ""]
      else
         raise Expected, "Could not parse evil message."
      end
   end

end

class TwistedMailbox < Mailbox
   def forget person
      @peers.delete person
   end
end

class TwistedMailer < Mailer

   # Expect someone else will begin the handshake
   #
   # British stereotype?
   def expect_handshake
      handshake = @mailbox.insecure_read Handshake
      handle_handshake handshake
   end

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

   def accept_handshake? from
      true
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

   def connect
      puts "Pretending to connect."
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

class ThreadList

   def initialize
      @semaphore = Mutex.new
      @threads = []
   end

   def push t
      @semaphore.synchronize do
         @threads.push t
      end
   end

   def kill
      h = HighLine.new
      h.ask h.color("PRESS ENTER TO SHUTDOWN THE SYSTEM", :magenta, :bold)
      @threads.each do |t| 
         begin
            t.kill
         rescue StandardError => e
            puts "ThreadList testing utility: Couldn't kill thread: #{e}"
         end
      end
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
   CARPS::init 0, "test/server"
   delete_key "bob"
   $alice_box = Mailbox.new send_bob, receive_bob, MessageParser.new(default_messages), SessionManager.new
   $alice = TwistedMailer.new $alice_address, $alice_box

   # Bob's stuff
   CARPS::init 0, "test/client"
   delete_key "alice"
   $bob_box = TwistedMailbox.new send_alice, receive_alice, MessageParser.new(default_messages.push EvilMessage), SessionManager.new
   $bob = TwistedMailer.new $bob_address, $bob_box
end

Then /^Alice initiates a handshake request and Bob accepts$/ do
   $alice.handshake $bob_address
   $bob.expect_handshake.join
end

Then /^a hacker pretending to be Alice sends a nefarious message to Bob$/ do
   $alice.evil $bob_address, EvilMessage.new
   $thrs.push Thread.fork { $bob.read EvilMessage }
end

Then /^a spoofer pretending to be Bob tries to make a handshake with Alice$/ do
   $bob.forget $alice_address 
   $bob.handshake $alice_address
   $thrs.push $alice.expect_handshake
end

When /^threading starts$/ do
   $thrs = ThreadList.new
end

When /^the user presses enter, threading stops$/ do
   $thrs.kill
end
