Given /^a text editor$/ do
   $editor = CARPS::Editor.load
end

Then /^edit some text$/ do
   Test::editor $editor
end
