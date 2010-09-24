require "mod/sheet_editor"

Given /^a character sheet schema$/ do
$schema = 
   {"name" => "text",
    "fruit" => "text",
    "days old" => "integer"}
end

Then /^fill in the character sheet$/ do
   editor = SheetEditor.new $schema
   editor.fill
end
