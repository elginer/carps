require "carps/protocol/message"

require "carps/service/game"
require "carps/service/client_parser"

include CARPS

When /^an invitation is sent$/ do
   $message = Invite.new "the dm", "the mod", "the description" 
end

Given /^a client parser$/ do
   $parser = client_parser 
end

Then /^emit the message$/ do
   $mail = $message.emit
end

Then /^parse the message$/ do
   message = $parser.parse $mail
   newmsg = message.emit
   unless $mail == newmsg
      raise StandardError, "Did not correctly parse invite:\nold emitings:\n#{$mail}\nnew emmittings:\n#{newmsg}"
   end
end
