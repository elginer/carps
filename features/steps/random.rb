require "carps/mod/dice"

require "carps/mod/interface"

def fill_randoms n
   $randoms = []
   n.times do
      $randoms.push yield
   end
end

Given /^(\d+) random integers between (\d+) and (\d+)$/ do |n, min, max|
   n = n.to_i
   min = min.to_i
   max = max.to_i
   fill_randoms n do
      Dice::rint min, max
   end
end

Given /^(\d+) random floats between (\d+) and (\d+)$/ do |n, min, max|
   n = n.to_i
   min = min.to_f
   max = max.to_f
   fill_randoms n do
      Dice::rfloat min, max
   end
end

Then /^ensure each of the random numbers are between (.+) and (.+)$/ do |min, max|
   min = min.to_i
   max = max.to_i
   works = $randoms.all? do |i|
      i >= min and i <= max
   end
   unless works
      raise StandardError, "Random generator is fucked."
   end
end

Given /^an interface to dice rolling$/ do
   $interface = RolePlayInterface.new
end

Then /^launch the probabalistic interface$/ do
   $interface.run
end
