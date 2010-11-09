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

      # Get the process singleton
      def Process.singleton
         unless @process
            @process = Process.load
         end
         @process
      end

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
         @semaphore.synchronize do
            uri = share resource
            if uri
               cmd = shell_cmd program, uri 
               puts "Launching: #{cmd}"
               system cmd
               stop_sharing
            end
         end
      end

      # Stop sharing a resource.
      def stop_sharing
         if @confirm
            UI::question "Press enter when the sub-program has completed."
         end
         begin
            DRb.stop_service
         rescue StandardError => e
            UI::put_error "Could not stop IPC: #{e}"
         end
      end

      # Run a block in a new process, allowing access the first argument by passing it a URI referring to a DRb object.
      #
      # If already running, then the process will not launch until till the first process has completed.
      def share resource
         begin
            local_only = ACL.new %w[deny all allow 127.0.0.1]
            DRb.install_acl local_only
            uri = "druby://localhost:" + @port.to_s 
            DRb.start_service uri, resource
            return uri
         rescue StandardError => e
            UI::put_error "Error beginning CARPS-side IPC: #{e}"
            return nil
         end
      end

      protected

      # Emit as hash
      def emit
         {"launch_terminal" => @term, "port" => @port, "wait" => @confirm}
      end

      # The command which would open a new window running the given command
      def shell_cmd program, uri
         program = program + " " + uri
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
   process.launch mut, "carps_ipc_test"
end
