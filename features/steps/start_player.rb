require "carps/service"

require "carps/protocol"

class MockPlayerGame
   def join_game mailer
      puts "Joining game."
   end

   def resume mailer
      puts "Resuming game"
   end

end

class MockPlayerConfig < Player::GameConfig
   def spawn
      MockPlayerGame.new
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
      @mail = CARPS::Invite.new "the dm", "test", "the description", "the session" 
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
