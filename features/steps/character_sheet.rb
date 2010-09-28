require "mod/sheet_editor"
require "mod/sheet_verifier"

require "yaml"

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

Then /^accept the valid sheet$/ do
   valid = $editor.valid? $sheet
   unless valid
      raise StandardError, "Failed valid sheet."
   end
end
