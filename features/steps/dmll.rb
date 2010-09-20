require "mod/dm/room"
require "mod/dm/reporter"
require "mod/dm/resource"
require "mod/dm/character"

require "mod/question"

Given /^all players are in the (.+)$/ do |room_name|
   $resource.everyone_in room_name
end

Then /^the reporter is registered with the resource manager$/ do
   $resource.reporter = $reporter
end

Given /^(.+) is in the (.+)$/ do |moniker, room|
   $resource.player_in moniker, room
end

Given /^a player called (.+)$/ do |moniker|
   $reporter.add_player moniker
end

Given /^a resource manager$/ do
   $resource = Resource.new "test_extra/resource"
end

Given /^a reporter$/ do
   $reporter = Reporter.new
end

Then /^customize report for (.+)$/ do |player|
   $reporter.edit player
end

Then /^take player turns$/ do
   turns = $reporter.player_turns
   turns.each do |moniker, turn|
      answers = turn.take
      answers.from = moniker
      answers.display
   end
end

Then /^ask everyone (.+)$/ do |question|
   $reporter.ask_everyone [Question.new(question)]
end

Then /^ask (.+) only: (.+)$/ do |player, question|
   $reporter.ask_player player, [Question.new(question)]
end

Given /^an NPC called (.+) of type (.+)$/ do |name, type|
   $resource.new_npc type, name, NPC
end

Then /^report the strength of the NPC paul to (.+)$/ do |name|
   $reporter.update_player name, "Paul's strength is #{NPC.paul.strength}"
end
