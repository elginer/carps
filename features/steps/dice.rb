require "carps/mod"

Then /^show the odds$/ do
   $odds = $dice.odds
   puts $odds
end

Given /^a d(\d+)$/ do |sides|
   $dice = CARPS::Dice::d sides.to_i
end

Then /^multiply by (\d+)$/ do |n|
   $dice * n.to_i
end

Then /^add (\d+)$/ do |n|
   $dice + n.to_i
end

Then /^add a d(\d+)$/ do |sides|
   $dice + CARPS::Dice::d(sides.to_i)
end

Then /^divide by (\d+)$/ do |n|
   $dice / n.to_i
end

Then /^if it's greater or equal to (\d+), and less than or equal to (\d+), the result is (\d+)$/ do |gte, lte, out|
   $dice.in_range gte.to_i..lte.to_i, out.to_i
end

Then /^if it's greater than (\d+), the result is (\d+)$/ do |compare, result|
   $dice.is :>, compare.to_i, result.to_i
end

Then /^multiply by a d(\d+)$/ do |sides|
   $dice * CARPS::Dice::d(sides.to_i)
end

Then /^divide by a d(\d+)$/ do |sides|
   $dice / CARPS::Dice::d(sides.to_i)
end

Then /^if it's greater or equal to (\d+), and less than or equal to (\d+), the result is a d(\d+)$/ do |gte, lte, sides|
   $dice.in_range gte.to_i..lte.to_i, CARPS::Dice::d(sides.to_i)
end

Then /^result (\d+) must be (\d+)$/ do |index, expect|
   results = $odds.keys.sort
   unless results[index.to_i] == expect.to_i
      raise StandardError, "Unexpected result!"
   end
end

Then /^each of the odds must be (\d+) \/ (\d+)$/ do |num, den|
   odds = $odds.values
   odds.each do |odd|
      unless odd == num.to_f / den.to_f
         raise StandardError, "Unexpected odds"
      end
   end
end

Then /^odd (\d+) must be (\d+) \/ (\d+)$/ do |index, num, den|
   results = $odds.keys.sort
   odds = results.map {|result| $odds[result]}
   unless odds[index.to_i] == num.to_f / den.to_f
      raise StandardError,  "Unexpected odd"
   end
end

Then /^roll the dice$/ do
   puts "The dice roll reads: #{$dice.roll}"
end
