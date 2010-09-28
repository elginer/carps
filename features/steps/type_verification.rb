require "mod/sheet_type"

Given /^an integer$/ do
   $val = 123
end

Then /^verify: (.+) as an (.+)$/ do |opt, type_name|
   type = TypeParser.parse type_name
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
