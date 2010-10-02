require "carps/crypt/mailbox"
require "carps/crypt/mailer"

require "carps/protocol/message"

require "carps/service/session"

require "fileutils"

require "highline"

include CARPS

class SessionManager
   def session
      @session
   end
end

class MailboxTestMessage < Message

   def MailboxTestMessage.parse blob
      if blob.match(/uhh/)
         [MailboxTestMessage.new, ""]
      else
         raise Expected, "Expected 'uhh'."
      end
   end

   def emit
      text = "uhh"
      addr = "bobby"
      sig = "hiya"
      mail = (V.addr addr) + (V.sig sig) + text + K.end
   end

end


# Test the mailbox by sending and receiving mails
class TestingIO

   def initialize
      @messages = []
   end

   # send the mailbox a message with a given session_id
   def in id
      $session.session = id
      $mailbox.send "wayhey", MailboxTestMessage.new.emit
      $session.none
   end

   # receive a message from the mailbox within 10 seconds or return nil
   def out
      msg = nil
      thrd = Thread.fork do
         msg = $mailbox.insecure_read MailboxTestMessage
      end
      10.times do
         if msg
            break
         else
            sleep 1
         end
      end
      thrd.kill
      msg
   end

   def send to, msg
      @messages.push msg
   end

   def read
      messages = @messages
      @messages = []
      messages
   end

   
end

When /^the user presses enter, continue$/ do
   h = HighLine.new
   h.ask "Press enter to continue..."
end

Then /^\.mail is cleaned$/ do
   FileUtils.rm_rf $CONFIG + ".mail"
   FileUtils.mkdir $CONFIG + ".mail"
end

Given /^a testing mailbox$/ do
   parser = MessageParser.new [MailboxTestMessage]
   $io = TestingIO.new
   if $mailbox
      $mailbox.shutdown
   end
   $mailbox = Mailbox.new $io, $io, parser, $session 
end

Then /^send mail with session (\d+) to the mailbox$/ do |session|
   $io.in session
end

Then /^receive mail with session (\d+)$/ do |session|
   mail = $io.out
   if not mail
      raise StandardError, "Did not receive mail with session #{session}"
   elsif not mail.session == session
      raise StandardError, "Received mail with session #{session}"
   end
end

Then /^set session to (\d+)$/ do |id|
   $session.session = id
end

Then /^check that the mail with session (\d+) has not been received$/ do |session|
   mail = $io.out
   if mail
      if mail.session == session
         raise StandardError, "Received mail with session #{mail.session}"
      end
   end
end
