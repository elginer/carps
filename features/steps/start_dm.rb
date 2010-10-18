require "carps/service/dm/config"
require "carps/service/dm/start"

require "carps/service/session"

include CARPS

class MockDmStartMailer
   def address
      "howdy"
   end
end

class MockGame

   def dm= dm
      @dm = dm
   end

   def start mailer
      puts "Starting game..."
   end

   def resume mailer
      puts "Resuming game..."
   end
end

class MockConfig < DM::GameConfig
   def spawn
      MockGame.new
   end
end

Then /^host a new game called (.+) with resource (.+) and mod (.+)$/ do |game_name, campaign, mod_name|
   $game = DM::GameConfig.new game_name, mod_name, campaign, "A game about things", ["joe@bloggs.com"], "session12345" 
end

Then /^save the game as (.+)$/ do |filename|
   $game.save
end

Then /^the dm resumes a previous game called (.+)$/ do |filename|
   $game = DM::GameConfig.load "games/" + filename
end

Then /^present the start game interface to the dm$/ do
   begin
      DM::StartInterface.start_game_interface MockDmStartMailer.new, MockConfig, $session 
   rescue SystemExit
   end
end
