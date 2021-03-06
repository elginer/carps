require "carps/util/process"

require "drb"

include Test

Given /an object to be mutated/ do
   $mut = Mutate.new
end

Then /^I should see 'It works' from the server side$/ do
   puts "On server side:"
   puts "\t" + $mut.works?
   unless $mut.working?
      raise StandardError, "IPC fucked."
   end
end

When /^the Process.launch method is called with the name of a ruby subprogram, which I should see in another window$/ do
   test_ipc CARPS::Process.singleton, $mut
   puts "DONE!"
end
