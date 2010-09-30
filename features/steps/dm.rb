require "carps/mod/dm/mod"
require "carps/mod/dm/resource"

require "carps/mod/dm/interface"

require "carps/mod/sheet_verifier"
require "carps/mod/sheet_editor"

include CARPS

class TestMod < DM::Mod
   def schema
      $schema
   end

   def update_barry status
      @reporter.update_player "barry", status
   end

end

class TestMailer

   def send addr, mail
      puts "Sending to #{addr}:"
      puts mail.emit
   end

   def barry
      editor = SheetEditor.new $schema, UserVerifier.new
      filled = {"name" => "bob", "fruit" => "kumquat", "days old" => 12}
      sheet = editor.fill filled
      sheet.from = $email
      @sheet = sheet
   end

   def read klass, from=nil
      msg = nil
      until msg
         msg = check
         sleep 1
      end
      msg
   end

   def check klass, from=nil
      if @sheet
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

$email = "barry@doodah.xxx"

When /^(.+) joins the mod$/ do |name|
   $mod.add_known_player name, $email 
   $mailer.barry
end

Then /^set (.+)'s status conditionally$/ do |name|
   player = $mod.player_stats(name)
   $mod.update_barry "You are a #{player["fruit"]}"
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
   DM::Interface.class_eval <<-END
   def quit
      @run = false
   end
   END
   interface = DM::Interface.new $mod
   interface.run
end

Then /^create an NPC called (.+) of type (.+)$/ do |name, type|
   $mod.new_npc type, name
end

Then /^report the strength of the NPC (.+) to (.+)$/ do |npc_name, name|
   npc = $mod.npc_stats npc_name
   $mod.update_player name, "#{npc_name}'s strength is #{npc["strength"]}"
end
