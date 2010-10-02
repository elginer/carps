require "carps/protocol/message"

require "carps/service/game"
require "carps/service/client_parser"

include CARPS

Given /^an invitation$/ do
   $invite = Invite.new "the dm", "the mod", "the description" 
end

Given /^a client parser$/ do
   $parser = client_parser 
end

Then /^emit the invitation$/ do
   $message = $invite.emit
end

Then /^parse the invitation$/ do
   invite = $parser.parse $message
   newmsg = invite.emit
   unless $message == newmsg
      raise StandardError, "Did not correctly parse invite:\nold emitings:\n#{$message}\nnew emmittings:\n#{newmsg}"
   end
end
