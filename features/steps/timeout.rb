require "carps/util/timeout"

Given /^a long running command$/ do
   $command = lambda {
      loop do
      end
   }
end

Then /^timeout the command after (\d+) second$/ do |t|
   begin
      CARPS::timeout t.to_i, "Test command 1" do
         $command.call
      end
   rescue Timeout::Error => e
      puts "The command was timed out as expected:"
      puts e.to_s
   end
end

Then /^give the command (\d+) second to complete$/ do |t|
   CARPS::timeout t.to_i, "test command 2" do
      $command.call
   end
end

Given /^a short command$/ do
   $command = lambda {
      puts "Hi honey!"
   }
end

