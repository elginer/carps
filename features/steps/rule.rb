require "carps/mod"

class OneTenAction < CARPS::Action

   def summary
      "The result was between one and ten."
   end

   def execute roll, sheet
      puts "Executing, roll was #{roll}, sheet was #{sheet}"
   end

end

class ElevenThirtyAction < CARPS::Action

   def summary
      "The result was between eleven and thirty."
   end

   def execute roll, sheet
      puts "Executing, roll was #{roll}, sheet was #{sheet}"
   end

end

class TestRule < CARPS::Rule

   def initialize
      super
      add_action 1..10, OneTenAction
      add_action :>=, 11, ElevenThirtyAction
   end

   protected

   def dice sheet
      CARPS::Dice::d 30
   end

end

Then /^show the odds for the rule$/ do
   $rule.show_odds $sheet
end

Given /^a rule which operates on a character sheet$/ do
   $rule = TestRule.new
end

Then /^apply the rule$/ do
   $rule.apply $sheet
end
