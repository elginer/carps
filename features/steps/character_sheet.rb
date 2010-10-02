require "carps/mod/sheet_editor"
require "carps/mod/sheet_verifier"

require "yaml"

include CARPS

Given /^a character sheet schema$/ do
$schema = 
   {"name" => "text",
    "fruit" => "text",
    "days old" => "integer"}
end

Given /^a sheet editor$/ do
   $editor = SheetEditor.new $schema, UserVerifier.new 
end

Then /^fill in the character sheet$/ do
   $sheet = $editor.fill
end

Then /^edit the character sheet again$/ do
   $editor.fill $sheet.dump
end

When /^a valid sheet is provided$/ do
   $sheet = CharacterSheet.new({"name" => "billy", "fruit" => "apple", "days old" => 11})
end

When /^an invalid sheet is provided$/ do
   $sheet = CharacterSheet.new({"name" => "billy", "fruit" => "apple", "days old" => "many"})
end


Then /^do not accept the invalid sheet$/ do
   valid = $editor.valid? $sheet
   if valid
      raise StandardError, "Passed invalid sheet"
   end
end

When /^an parsable sheet is provided$/ do
   $input = V.character_sheet "strength: 10"
end

Then /^parse the sheet$/ do
   sheet, blob = CharacterSheet.parse $input
   puts "Parsed:"
   sheet.display
end

When /^an unparsable sheet is provided$/ do
   $input = V.character_sheet "a: a: a"
end

Then /^do not parse the sheet$/ do
   begin
      CharacterSheet.parse $input
      raise Exception, "Parsed the sheet!"
   rescue Expected => e
      puts e.to_s
   end
end

Then /^accept the valid sheet$/ do
   valid = $editor.valid? $sheet
   unless valid
      raise StandardError, "Failed valid sheet."
   end
end
