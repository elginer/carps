require "carps/mod"

class TestRule < CARPS::Rule
end

Given /^a rule which operates on a character sheet$/ do
   $rule = TestRule.new $sheet 
end

Then /^apply the rule$/ do
  pending # express the regexp above with the code you wish you had
end
