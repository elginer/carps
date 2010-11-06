require "carps/mod"

Given /^a character sheet schema$/ do
   $schema =Sheet::Schema.new(
      {"name" => "text",
       "fruit" => "text",
       "days old" => "integer"
      })
end

Given /^a sheet editor$/ do
   $editor = Sheet::Editor.new $schema, Sheet::UserVerifier.new 
end

Then /^fill in the character sheet$/ do
   $sheet = Sheet::Character.new 
   $editor.fill $sheet
end

Then /^edit the character sheet again$/ do
   $editor.fill $sheet
end

When /^a valid sheet is provided$/ do
   $sheet = Sheet::Character.new({"name" => "billy", "fruit" => "apple", "days old" => 11})
end

When /^an invalid sheet is provided$/ do
   $sheet = Sheet::Character.new({"name" => "billy", "fruit" => "apple", "days old" => "many"})
end


Then /^do not accept the invalid sheet$/ do
   valid = $editor.valid? $sheet
   if valid
      raise StandardError, "Passed invalid sheet"
   end
end

When /^an parsable sheet is provided$/ do
   stats = <<-END
Name: A
Biography: 
The Readies: 0
The Old Grey Matter: 0
The Outer Crust: 0
Vim & Vigour: 0
Luck: 0
Chances: 0
Romantic Resistance: 0
Tolerance for Alcohol: 0
Conscience: 0
Etiquette: 0
Gentleman's Gentleman: 
Sports Car: 
Student of the Turf: false
Specialist Interest: 
Connections: 
Difficult Relation: 
Good Sportsman: 
END
   $input = V.character_sheet stats
end

Then /^parse the sheet$/ do
   sheet, blob = Sheet::NewSheet.parse $input
   puts "Parsed:"
   sheet.display
end

When /^an unparsable sheet is provided$/ do
   $input = V.character_sheet "a: a: a"
end

Then /^do not parse the sheet$/ do
   begin
      Sheet::NewSheet.parse $input
      raise Exception, "Parsed the sheet!"
   rescue Expected => e
      puts e.message
   end
end

Then /^accept the valid sheet$/ do
   valid = $editor.valid? $sheet
   unless valid
      raise StandardError, "Failed valid sheet."
   end
end
