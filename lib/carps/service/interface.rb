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

require "carps/util/question"

require "carps/util/warn"

require "carps/util/error"

module CARPS

   # A basic user interface
   #
   # Subclass this interface to provide commands
   class Interface

      def initialize 
         @commands = {}
         add_command "help", "Displays this help message."
      end

      # Ensure consistency 
      def consistent!
         # Check we're working
         @commands.each_key do |cmd|
            unless respond_to?(cmd)
               warn "This menu was intended to provide a '#{cmd}' command!", 
               "However, it has been ommitted due to a programmer error."
               @commands.delete cmd
            end
         end
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

      # Add a command which receives the text after it, as one, argument: a possibly empty string
      def add_raw_command name, help, *args
         @commands[name] = {"help" => help, "args" => args}
         eval <<-END
         def exec_#{name} args
            #{name} args.join " "
         end
         END
      end

      def run
         consistent!
         help
         repl
      end

      protected

      # Check the args are of the correct length
      def check args, length
         if args.length == length
            yield *args
         else
            put_error "Expected #{length} parameters."
         end
      end

      def execute cmd
         if cmd.empty?
            empty_line
         else
            if @commands.member? cmd[0]
               self.send "exec_" + cmd[0], cmd[1..-1]
            else
               put_error "Unknown command: '" + cmd[0] + "'. Try 'help'."
            end
         end
      end

      def empty_line
         put_error "You must enter a command.  Try 'help'."
      end

      def help
         puts ""
         puts "The available commands, and their formal parameters, are:"
         @commands.each do |cmd, info|
            puts ""
            puts cmd + " " + info["args"].join(" ")
            puts info["help"]
         end
         puts ""
      end

      def repl
         loop do
            rep
         end
      end

      def rep 
        line = question "Enter command:"
        cmd = line.split /\s+/
        execute cmd
      end

   end

   class QuitInterface < Interface

      def initialize
         super
         add_command "quit", "Quit the program"
      end

      protected

      def quit
         @run = false
      end

      def repl
         @run = true
         while @run
            rep
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

end
