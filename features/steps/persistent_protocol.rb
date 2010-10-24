require "carps/protocol/message"

class TestMessage < Message
end

Given /^a persistent message$/ do
   $message = TestMessage.new
   $message.from = "someone"
end

Then /^save the message, noting the file name$/ do
   $file = $message.save "BLAHBLAHBLAH"
end

Then /^make sure the file exists$/ do
   unless File.exists?($file)
      raise StandardError, "TestMessage did not save itself."
   end
end

Then /^delete the message$/ do
   $message.delete
end

Then /^make sure the file was deleted$/ do
   if File.exists?($file)
      raise StandardError, "TestMessage did not delete itself."
   end
end
