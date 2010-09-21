# Copyright 2010 John Morrice
 
# This file is part of CARPS.

# CARPS is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# CARPS is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with CARPS.  If not, see <http://www.gnu.org/licenses/>.

require "util/question"

# A basic user interface
#
# Subclass this interface to provide commands
class Interface

   def initialize 
      @commands = {}
      add_command "help", "Displays this help message."
      add_command "quit", "Exit the program."
   end

   # Add a command
   #
   #
   # You must also create a method 
   # called name which takes each of args as parameters
   def add_command name, help, *args
      @commands[name] = {"help" => help, "args" => args}
      eval <<-END
         def exec_#{name} args
            check args, #{args.length} do
               #{name} *args
            end
         end
      END
   end

   def run
      help
      repl
   end

   protected

   def quit
      @run = false
   end

   # Check the args are of the correct length
   def check args, length
      if args.length == length
         yield *args
      else
         puts "Error:  Expected #{length} parameters."
      end
   end

   def execute cmd
      if cmd.empty?
         empty_line
      else
         if @commands.member? cmd[0]
            self.send "exec_" + cmd[0], cmd[1..-1]
         else
            puts "Error: unknown command: '" + cmd[0] + "'. Try 'help'."
         end
      end
   end

   def empty_line
      puts "Error: you must enter a command.  Try 'help'."
   end

   def help
      puts "The available commands, and their formal parameters, are:"
      @commands.each do |cmd, info|
         puts ""
         puts cmd + " " + info["args"].join(" ")
         puts info["help"]
      end
   end

   def repl
      @run = true
      while @run
         line = question "Enter command:"
         cmd = line.split /\s+/
         execute cmd
      end
   end

end

# Interface which can alter program execution (ie, by terminating)
module ControlInterface 

   def quit
      puts "Bye!"
      exit
   end

end
