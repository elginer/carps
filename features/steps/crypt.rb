# Test cryptography mechanism

require "email/config"

require "crypt/default_messages"

require "protocol/message"

require "util/process"

Given /^two peers, Alice and Bob$/ do
   alice_mail = EmailConfig.new "email.yaml", MessageParser.new(default_messages)
   bob_mail = EmailConfig.new "server_email.yaml", MessageParser.new(default_messages)
   $alice = alice_mail.mailer
   $bob = bob_mail.mailer
   $bob_address = bob_mail.address
   init_process "process.yaml"
end

Then /^Alice initiates a handshake request and Bob accepts$/ do
   Thread.fork do
      $alice.handshake $bob_address
   end
   $bob.expect_handshake
end
