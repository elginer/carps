require "carps/util/process"

require "drb"

include CARPS
include Test

Given /an object to be mutated/ do
   $mut = Mutate.new
end

When /^the \$process.ashare method is run with a computation to mutate the object$/ do
   mutate $process, mut
end

Then /^I should see 'It works' from the server side$/ do
   puts "On server side:"
   puts "\t" + $mut.works?
end

When /^the \$process.launch method is called with the name of a ruby subprogram, which I should see in another window$/ do
   test_ipc $process, $mut
end
