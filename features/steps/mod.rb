require "carps/service/dm/config"
require "carps/service/player/config"

Given /^a dm game config$/ do
   $game_config = DM::GameConfig.new "test", "fun campaign", "game about stuff", [], $session
end

Then /^resume the mod$/ do
   game = $game_config.spawn
   game.resume nil
end

Given /^a player game config$/ do
   $game_config = Player::GameConfig.new "test", "the dm", "game about stuff", $session
end
