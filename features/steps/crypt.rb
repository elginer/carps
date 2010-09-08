# Test cryptography mechanism

require "email/config"

require "crypt/default_messages"

require "protocol/message"

require "util/init"

Given /^two peers, Alice and Bob$/ do
   init "client"
   alice_mail = EmailConfig.new "email.yaml", MessageParser.new(default_messages)
   init "server"
   bob_mail = EmailConfig.new "email.yaml", MessageParser.new(default_messages)
   $alice = alice_mail.mailer
   $bob = bob_mail.mailer
   $bob_address = bob_mail.address
end

Then /^Alice initiates a handshake request and Bob accepts$/ do
   Thread.fork do
      $alice.handshake $bob_address
   end
   $bob.expect_handshake
end
