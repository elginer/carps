require "carps/mod"

class OneTenAction < CARPS::Action

   def name
      "one to ten"
   end

   def summary
      "The result was between one and ten."
   end

   def execute roll, sheet
      puts "Executing, roll was #{roll}, sheet was #{sheet}"
   end

end

class ElevenThirtyAction < CARPS::Action

   def name
      "eleven to thirty"
   end

   def summary
      "The result was between eleven and thirty."
   end

   def execute roll, sheet
      puts "Executing, roll was #{roll}, sheet was #{sheet}"
   end

end

class TestRule < CARPS::Rule

   def dice sheet
      CARPS::Dice::d 30
   end

   def actions
      [
         [1..10, OneTenAction],
         [11..30, ElevenThirtyAction]
      ]
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
