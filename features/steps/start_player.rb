require "service/player/start"
require "service/player/config"

require "protocol/message"

class MockPlayerGame
   def join_game
      puts "Joining game."
   end

   def resume
      puts "Resuming game"
   end

   def mod
      "fruit"
   end
end

class PlayerStartMailer
   def read type, from = nil
      if @mail
         mail = @mail
         @mail = nil
         return mail
      else
         return nil
      end
   end

   def send to, message
      puts "Sending message to #{to}:"
      puts message
   end

   def invite
      @mail = Invite.new MockPlayerGame.new
   end
end

Given /^a mailer stub for the player start interface$/ do
   $mailer = PlayerStartMailer.new
end

When /^an invite is sent to the player$/ do
   $mailer.invite
end

Then /^present the start game interface to the player$/ do
   child = fork do
      PlayerStartInterface.start_game_interface $mailer,
         PlayerGameConfig,
         MessageParser.new(default_messages)
   end
   Process.wait child
end
