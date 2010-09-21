require "mod/dm/mod"
require "mod/dm/resource"

require "mod/dm/interface"

class TestMod < Mod
   def schema
      {"name" => "text",
       "fruit" => "text",
       "days old" => "integer"}
   end

   def update_barry status
      @reporter.update_player "barry", status
   end

end

class TestMailer

   def send addr, mail
      if mail.class == CharacterSheetRequest
         sheet = mail.fill
         sheet.from = $email
         @sheet = sheet
      end
   end

   def read klass
      if klass == Answers
         loop do
            sleep 1
         end
      elsif klass == CharacterSheet
         until @sheet
            sleep 1
         end
         sheet = @sheet
         @sheet = nil
         return sheet
      end
   end

end

Given /^a DM mod$/ do
   resource = Resource.new "test_extra/resource"
   $mailer = TestMailer.new
   $mod = TestMod.new resource, $mailer
end

When /^barry joins the mod$/ do
   $email = "barry@doodah.xxx"
   $mod.add_known_player "barry", $email 
end

Then /^set barry's status conditionally$/ do
   $mod.update_barry "You are a #{PC.barry.fruit}"
end

Then /^preview player turns$/ do
   $mod.inspect_reports
end

Then /^check barry's sheet$/ do
   received = false
   until received
      received = $mod.check_mail
      sleep 1
   end
end

Then /^present a user interface to the DM$/ do
   interface = DMInterface.new $mod
   child = fork do
      interface.run
   end
   Process.wait child
end

Then /^create an NPC called (.+) of type (.+)$/ do |name, type|
   $mod.new_npc type, name
end

Then /^report the strength of the NPC paul to (.+)$/ do |name|
   $mod.update_player name, "Paul's strength is #{NPC.paul.strength}"
end
