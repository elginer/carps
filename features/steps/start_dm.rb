require "carps/service/dm/config"

require "carps/service/dm/start"

include CARPS

class MockGame
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
   $game = DM::GameConfig.new mod_name, campaign, "A game about things", ["joe@bloggs.com"]
end

Then /^save the game as (.+)$/ do |filename|
   $game.save filename
end

Then /^the dm resumes a previous game called (.+)$/ do |filename|
   $game = DM::GameConfig.load "games/" + filename
end

Then /^present the start game interface to the dm$/ do
   child = fork do
      DM::StartInterface.start_game_interface nil, MockConfig
   end
   Object::Process.wait child
end
