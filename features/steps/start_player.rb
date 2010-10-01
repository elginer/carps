require "carps/service/player/start"
require "carps/service/player/config"

require "carps/protocol/message"

include CARPS

class MockPlayerGame
   def join_game mailer
      puts "Joining game."
   end

   def resume mailer
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

class MockPlayerConfig < Player::GameConfig
   def spawn
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
      @mail.session = "dandy motherfucker!"
   end
end

Given /^a mailer stub for the player start interface$/ do
   $mailer = PlayerStartMailer.new
end

When /^an invite is sent to the player$/ do
   $mailer.invite
end

Then /^present the start game interface to the player$/ do
   begin
      Player::StartInterface.start_game_interface $mailer, MockPlayerConfig, $session
   rescue SystemExit
   end
end
