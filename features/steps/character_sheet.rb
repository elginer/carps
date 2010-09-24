require "mod/sheet_editor"
require "mod/sheet_verifier"

Given /^a character sheet schema$/ do
$schema = 
   {"name" => "text",
    "fruit" => "text",
    "days old" => "integer"}
end

Then /^fill in the character sheet$/ do
   editor = SheetEditor.new $schema, NullVerifier.new 
   $sheet = editor.fill
end

Then /^edit the character sheet again$/ do
   editor = SheetEditor.new $schema, NullVerifier.new
   editor.fill $sheet.dump
end
