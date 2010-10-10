require "carps/service/dm/config"
require "carps/service/player/config"

Given /^a dm game config, for mod (.+)$/ do |mod|
   $game_config = DM::GameConfig.new "save_test", mod, "fun campaign", "game about stuff", [], $session
end

Then /^resume the mod$/ do
   game = $game_config.spawn
   game.resume nil
end

Then /^load the DM mod$/ do
   config = DM::GameConfig.load "games/save_test.yaml"
   game = config.spawn
   game.resume nil
end

Given /^a player game config, for mod (.+)$/ do |mod|
   $game_config = Player::GameConfig.new "save_test", "test", "the dm", "game about stuff", $session
end
