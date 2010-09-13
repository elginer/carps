Given /^carps is initialized with (.+)$/ do |config|
   init config
end

Given /^an editor$/ do
   $editor = Editor.new "editor.yaml"
end
