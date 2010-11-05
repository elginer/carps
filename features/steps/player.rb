require "carps/mod/player/mod"
require "carps/mod/player/interface"

require "carps/mod/client_turn"
require "carps/mod/status_report"

class PlayerTestMod < Player::Mod
   def schema
      $schema
   end

   def description
      <<-END
You are testing the CARPS player mod system and interface.
This text was returned by the description method of the test mod.

You are about to fill in a character sheet for the 'fruit' game used
throughout the CARPS testing utility.
END
   end

end

class PlayerModTestMailer
   def relay message
      puts "Sending:"
      puts message.emit
   end

   def check type
      mail = @mail
      @mail = nil
      return mail
   end

   def turn t
      @mail = t
   end

   def save mod
      puts "Saving"
      puts mod.to_s
   end

end

Then /^test all inputs to the player's interface$/ do
   commands = []
   commands.push [:act]
   commands.push [:edit]
   commands.push [:sheet]
   test_interface $interface, commands
end


Given /^a player test mailer$/ do
   $mailer = PlayerModTestMailer.new 
end

Given /^a player mod$/ do
   $mod = PlayerTestMod.new
   $mod.mailer = $mailer
end

When /^the player receives turn information$/ do
   status = StatusReport.new "You are a player don't you know!"
   questions = [Question.new("Who are you, you strange man?")]
   t = ClientTurn.new Sheet::NewSheet.new({}), status, questions
   $mailer.turn t 
end

Given /^a player interface$/ do
   $interface = Player::Interface.new $mod
end

Then /^present a user interface to the player$/ do
   begin
      $interface.run
   rescue SystemExit => e
      "Quit program: #{e}"
   end
end
