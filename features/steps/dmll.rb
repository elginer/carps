require "mod/room"
require "mod/reporter"
require "mod/resource"

Given /^all players are in the (.+)$/ do |room_name|
   $resource.everyone_in room_name
end

Given /^(.+) is in the (.+)$/ do |moniker, room|
   $resource.player_in moniker, room
end

Given /^an email address for player (\d)$/ do |num|
  $last_email = num + "@players"
end

Then /^associate player (\d+)'s email address with a moniker$/ do |num|
   $reporter.add_player $last_email
end

Given /^a resource manager$/ do
   $resource = Resource.new "test_extra/resource"
end

Given /^a reporter$/ do
   $reporter = Reporter.new $resource
end

Then /^customize report for (.+)$/ do |player|
   $reporter.edit player, $editor
end

Then /^describe the room to each player$/ do
   turns = $reporter.player_turns
   turns.each do |mail, turn|
      puts "For " + mail + ":"
      answers = turn.take
      answers.display
   end
end
