require "mod/player/mod"
require "mod/player/interface"

require "mod/client_turn"
require "mod/status_report"

class PlayerTestMod < PlayerMod
   def schema
      $schema
   end
end

class PlayerModTestMailer
   def send message
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

end

Given /^a player test mailer$/ do
   $mailer = PlayerModTestMailer.new 
end

Given /^a player mod$/ do
   $mod = PlayerTestMod.new $mailer
end

When /^the player receives turn information$/ do
   status = StatusReport.new "You are a player don't you know!"
   questions = [Question.new("Who are you, you strange man?")]
   t = ClientTurn.new CharacterSheet.new({}), status, questions
   $mailer.turn t 
end

Then /^present a user interface to the player$/ do
   face = PlayerInterface.new $mod
   child = fork do
      face.run
   end
   Process.wait child
end
