require "carps/mod/dm/room"
require "carps/mod/dm/reporter"
require "carps/mod/dm/resource"
require "carps/mod/dm/character"

include CARPS

Then /^the reporter is registered with the resource manager$/ do
   $resource.reporter = $reporter
end

Given /^(.+) are in the (.+)$/ do |monikers_text, room|
   monikers = monikers_text.split
   $resource.players_in monikers, room
end

Given /^a resource manager$/ do
   $resource = Resource.new "resource"
end

Given /^a reporter$/ do
   $reporter = Reporter.new
end

Then /^customize report for (.+)$/ do |player|
   $reporter.edit player
end

Then /^take turns for (.+)/ do |name_text|
   names = name_text.split
   turns = $reporter.player_turns names
   turns.each do |moniker, turn|
      answers = turn.take
      answers.from = moniker
      answers.display
   end
end

Then /^ask (.+): (.+)$/ do |players_text, question|
   players = players_text.split
   players.each do |player|
      $reporter.ask_player player, question
   end
end

Then /^create an NPC of type human$/ do
   npc = $resource.new_npc "human"
   unless npc
      raise "Could not load human"
   end
   puts npc.to_s
end
