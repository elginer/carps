require "service/dm/config"

require "service/dm/start"

class MockGame
   def start
      puts "Starting game..."
   end

   def resume
      puts "Resuming game..."
   end
end

class MockConfig < DMGameConfig
   def spawn mailer
      MockGame.new
   end
end

Then /^host a new game called (.+) with resource (.+) and mod (.+)$/ do |game_name, campaign, mod_name|
   $game = DMGameConfig.new mod_name, campaign, "A game about things", ["joe@bloggs.com"]
end

Then /^save the game as (.+)$/ do |filename|
   $game.save filename
end

Then /^the dm resumes a previous game called (.+)$/ do |filename|
   $game = DMGameConfig.load "games/" + filename
end

Then /^present the start game interface to the dm$/ do
   child = fork do
      start = DMStartInterface.start_game_interface nil, MockConfig, []
   end
   Process.wait child
end
