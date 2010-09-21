require "service/interface"

class Cheesey < Interface

   include ControlInterface

   def initialize
      super
      add_command "cheese", "Have some cheese.", "AGE", "TYPE"
      add_command "cracker", "Have a cracker."
   end

   def cheese age, type
      puts "Mmmmm, #{age} #{type}!"
   end

   def cracker
      puts "You may have a cracker."
   end

end

Given /^a cheesey interface$/ do
   $interface = Cheesey.new
end

Then /^present the cheesey interface to the user$/ do
   child = fork do
      $interface.run
   end
   Process.wait child 
end
