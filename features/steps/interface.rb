require "carps/service/interface"

class Cheesey < QuitInterface

   include ControlInterface

   def initialize
      super
      add_command "cheese", "Have some cheese.", "AGE", "TYPE"
      add_raw_command "echo", "I say what you say!", "MESSAGE"
      add_command "cracker", "Have a cracker."
   end

   def echo arg
      puts arg
   end

   def cheese age, type
      puts "Mmmmm, #{age} #{type}!"
   end

   def cracker
      puts "You may have a cracker."
   end

end

class Broken < Cheesey

   def initialize
      super
      add_command "wine", "Have a glass of wine", "YEAR", "TYPE"
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

# Test an interface by calling the commands
def test_interface interface, commands
   commands.each do |cmd|
      interface.send *cmd
   end
end

Given /^a broken interface created by a drunk$/ do
   $interface = Broken.new
end

Then /^present the interface, reporting the mistake to the user$/ do
      child = fork do
      $interface.run
   end
   Process.wait child 
end
