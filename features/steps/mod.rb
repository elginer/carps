require "carps/service/dm/config"
require "carps/service/player/config"

require "carps/service/start/mailer"

Given /^a dm game config, for mod (.+)$/ do |mod|
   $game_config = DM::GameConfig.new "save_test", mod, "fun campaign", "game about stuff", $session.key, "dm@dm.dm"
end

Then /^resume the mod$/ do
   game = $game_config.spawn
   game.resume ModMailer.new nil, $game_config
end

Then /^load the DM mod$/ do
   $game_config = DM::GameConfig.load "games/save_test.yaml"
end

Then /^load the Player mod$/ do
   $game_config = Player::GameConfig.load "games/save_test.yaml"
end

Given /^a player game config, for mod (.+)$/ do |mod|
   $game_config = Player::GameConfig.new "save_test", mod, "the dm", "game about stuff", $session.key
end
