require "carps/mod"

require "yaml"

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

   def relay addr, mail
      puts "Sending to #{addr}:"
      puts mail.emit
   end

   def save mod
      puts "Saving: #{mod.to_yaml}" 
   end

   def barry
      @sheet = Sheet::NewSheet.new({"name" => "bob", "fruit" => "kumquat", "days old" => 12})
      @sheet.from = "barry"
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

# Test an interface by calling the commands
def test_interface interface, commands
   commands.each do |cmd|
      interface.send *cmd
   end
end

Given /^a DM mod$/ do
   resource = Resource.new "resource"
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
   $mod.update_barry "You are a #{player.visit{|sheet| sheet["fruit"]}}"
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

Given /^a DM interface$/ do
   $interface = DM::Interface.new $mod
end

Then /^test all inputs to interface$/ do
   commands = []
   commands.push [:mail]
   commands.push [:done]
   commands.push [:players]
   commands.push [:npcs]
   commands.push [:player, "bob"]
   commands.push [:player, "barry"]
   commands.push [:spawn, "orange", "dick"]
   commands.push [:npc, "dick"]
   commands.push [:npc, "bob"]
   commands.push [:npcs]
   commands.push [:players]
   commands.push [:done]
   commands.push [:warp, "cave"]
   commands.push [:warp, "hello"]
   commands.push [:decree]
   commands.push [:edit, "barry"]
   commands.push [:edit, "bob"]
   commands.push [:census]
   commands.push [:pcstats, "bob"]
   commands.push [:npcstats, "bob"]
   commands.push [:pcstats, "barry"]
   commands.push [:npcstats, "dick"]
   commands.push [:survey]
   commands.push [:ask, "bob"]
   commands.push [:ask, "barry"]
   commands.push [:inspect, "bob"]
   commands.push [:inspect, "barry"]
   commands.push [:nuke]
   commands.push [:silence]
   commands.push [:futile]
   commands.push [:remit, "bob"]
   commands.push [:remit, "barry"]
   commands.push [:supress, "bob"]
   commands.push [:supress, "barry"]
   commands.push [:done]
   commands.push [:save]
   test_interface $interface, commands
end

Then /^present a user interface to the DM$/ do
   $interface.run
end

Then /^create an NPC called (.+) of type (.+)$/ do |name, type|
   $mod.new_npc type, name
end

Then /^report the strength of the NPC (.+) to (.+)$/ do |npc_name, name|
   npc = $mod.npc_stats npc_name
   $mod.update_player name, "#{npc_name}'s strength is #{npc.visit{|sheet| sheet["strength"]}}"
end
