require "carps/mod/dice"

Then /^show the odds$/ do
   puts $dice.odds
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

Then /^multiply by a d(\d+)$/ do |sides|
   $dice * CARPS::Dice::d(sides.to_i)
end

Then /^divide by a d(\d+)$/ do |sides|
   $dice / CARPS::Dice::d(sides.to_i)
end

Then /^if it's greater or equal to (\d+), and less than or equal to (\d+), the result is a d(\d+)$/ do |gte, lte, sides|
   $dice.in_range gte.to_i..lte.to_i, CARPS::Dice::d(sides.to_i)
end
