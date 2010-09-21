require "service/game/config"

require "service/dm/start"

Then /^host a new game called (.+) with resource (.+) and mod (.+)$/ do |game_name, campaign, mod_name|
   $game = GameConfig.new mod_name, campaign, "A game about things", ["joe@bloggs.com"]
end

Then /^save the game as (.+)$/ do |filename|
   $game.save filename
end

Then /^the dm resumes a previous game called (.+)$/ do |filename|
   $game = GameConfig.load "games/" + filename
end

Then /^present the start game interface to the dm$/ do
   start = StartGameInterface.new
   start.run
end
