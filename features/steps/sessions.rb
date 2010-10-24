require "carps/service/session"

class ValidSessionMessage

   def session
      "killingjoke"
   end

end

class InvalidSessionMessage

   def session
      "simplyred"
   end

end

Given /^a session manager$/ do
   $session = SessionManager.new
   $session.session = "killingjoke"
end

Then /^accept a message meant for this session$/ do
   now = $session.belong? ValidSessionMessage.new
   unless now
      raise StandardError, "SessionManager did not accept valid message."
   end
end

Then /^deny a message intended for another session$/ do
   now = $session.belong? InvalidSessionMessage.new
   if now
      raise StandardError, "SessionManager accepted invalid message."
   end
end

