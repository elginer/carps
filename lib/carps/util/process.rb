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

require "carps/util/config"

require "carps/ui/error"

require "drb"
require "drb/acl"

require "set"

module CARPS

   # Responsible for launching other CARP processes
   class Process < SystemConfig

      def Process.filepath
         "process.yaml"
      end

      def initialize term, port, confirm = false
         load_resources term, port, confirm
      end

      def parse_yaml conf
         term = read_conf conf, "launch_terminal"
         port = read_conf(conf, "port").to_i
         confirm = read_conf conf, "wait"
         [term, port, confirm]
      end

      def load_resources term, port, confirm
         @port = port
         @term = term
         @semaphore = Mutex.new
         @confirm = confirm
      end

      # Launch a ruby program in another terminal window, which can access the resource over drb
      def launch resource, program
         ashare resource do |uri|
            program = program + " " + uri 
            cmd = shell_cmd program 
            puts "Launching: #{cmd}"
            begin
               exec cmd
            rescue StandardError => e
               UI::put_error "Problem launching sub-program: #{e}"
            end
         end
      end

      # Run a block in a new process, allowing access the first argument by passing it a URI referring to a DRb object.
      #
      # If already running, then the process will not launch until till the first process has completed.
      def ashare resource
         Thread.fork do
            @semaphore.synchronize do
               begin
                  local_only = ACL.new %w[deny all allow 127.0.0.1]
                  DRb.install_acl local_only
                  uri = "druby://localhost:" + @port.to_s 
                  DRb.start_service uri, resource
                  child = fork do
                     begin
                        DRb.start_service
                     rescue StandardError => e
                        UI::put_error "Problem starting inter-process communication in the sub-program: #{e}"
                     end
                     yield uri
                  end
                  Object::Process.wait child
                  if @confirm
                     UI::question "Press enter when the sub-program has completed."
                  end
                  DRb.stop_service
               rescue StandardError => e
                  UI::put_error "Malfunction in inter-process communication: #{e}"
               end
            end
         end
      end

      protected

      # Emit as hash
      def emit
         {"launch_terminal" => @term, "port" => @port, "wait" => @confirm}
      end

      # The command which would open a new window running the given command
      def shell_cmd program
         @term.gsub "%cmd", program
      end

   end

   # Testing utilities, for the wizard (also used for unit tests)
   module Test
      class Mutate

         include DRbUndumped

         def initialize
            @works = "WORK IT DOES NOT!"
            @working = false
         end

         def mutate!
            @works = "It works!"
            @working = true
         end

         def works?
            @works
         end

         def working?
            @working
         end

      end
   end

end

# Test IPC
def test_ipc process, mut
   child = process.launch mut, "carps_ipc_test"
   child.join
end
