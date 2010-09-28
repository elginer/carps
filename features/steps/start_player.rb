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

   def dm
      "bob"
   end

   def desc
      "A game about stuff"
   end
end

class MockPlayerConfig < PlayerGameConfig
   def spawn mailer
      MockGame.new
   end
end

class PlayerStartMailer

   def read klass, from=nil
      msg = nil
      until msg
         msg = check
         sleep 1
      end
      msg
   end

   def check klass, from=nil
      if @mail
         mail = @mail
         @mail = nil
         return mail
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
         MockPlayerConfig,
         MessageParser.new(default_messages)
   end
   Process.wait child
end
