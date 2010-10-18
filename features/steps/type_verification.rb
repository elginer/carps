require "carps/mod"

require "yaml"

Given /^an integer$/ do
   $val = 123
end

Then /^verify: (.+) as a (.+)$/ do |opt, type_name|
   type = Sheet::TypeParser.parse type_name
   accepted, coerced = type.verify $val
   pass = opt == "accept"
   unless (pass and accepted) or (not pass and not accepted)
      raise StandardError, "Verification mechanism fucked: should pass #{pass}, did pass #{accepted}"
   end
end

Given /^a nil value$/ do
   $val = nil
end

Given /^a string$/ do
   $val = "howdy!"
end

Given /^'yes'$/ do
   $val = YAML.load "yes"
end

Given /^'bronze'$/ do
   $val = "bronze"
end

Given /^'gold'$/ do
   $val = "gold"
end
