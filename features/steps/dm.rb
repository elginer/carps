require "mod/room"
require "mod/reporter"

require "util/question"

$monikers = {}

class MockReporter < Reporter

end

Given /^a room$/ do
   $room = Room.new "test_extra/cave.desc"
end

Then /^describe the room to the players$/ do
   puts $room.describe
end

Given /^an email address for player (\d)$/ do |num|
  $last_email = num + "@players"
end

Then /^associate player (\d+)'s email address with a moniker$/ do |num|
   mon = ask "Enter moniker for " + $last_email 
   $monikers[mon] = $last_email 
end

Given /^a reporter$/ do
   $reporter = MockReporter.new
   $reporter.current_room $room
end

Then /^customize report for all players$/ do
   $reporter.global_edit $editor
end

Then /^describe the room to each player$/ do
   turns = $reporter.player_turns $monikers
   turns.each do |mail, turn|
      puts "For " + mail + ":"
      answers = turn.take
      answers.display
   end
end
