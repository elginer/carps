require "carps/ui"

Given /^\$SAFE is (\d+)$/ do |level|
   $SAFE = level.to_i
end

Then /^allow checking a file exists in response to user input$/ do
   File.exists?(question "Enter file name to check existense of")
end

Then /^disallow eval in response to user input$/ do
   begin
      eval(question "Enter arbitrary ruby statement")
   rescue InsecureOperation => e
      puts "Recovered from Insecure Operation"
   end
end
