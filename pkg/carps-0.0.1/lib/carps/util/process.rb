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

require "drb"
require "drb/acl"

require "set"

module CARPS

   # Responsible for launching other CARP processes
   class CARPProcess < YamlConfig
      def parse_yaml conf
         term = read_conf conf, "launch_terminal"
         port = read_conf(conf, "port").to_i
         [term, port]
      end

      def load_resources term, port
         @port = port
         @term = term
         @used = Set.new
         @semaphore = Mutex.new
      end

      # Launch a ruby program in another terminal window, which can access the resource over drb
      def launch resource, program
         ashare resource, lambda { |uri|
            program = program + " " + uri 
            cmd = shell_cmd program 
            puts "Launching: #{cmd}"
            exec cmd
         }
      end

      # The command which would open a new window running the given command
      def shell_cmd program
         @term.gsub "%cmd", program
      end

      # Run computation in the second argument in a new process allowing access the first
      #
      # If already running, then the process will not launch until till the first process has completed.
      def ashare resource, computation
         Thread.fork do
            @semaphore.synchronize do
               local_only = ACL.new %w[deny all allow 127.0.0.1]
               DRb.install_acl local_only
               uri = "druby://localhost:" + @port.to_s 
               DRb.start_service uri, resource
               child = fork do
                  DRb.start_service
                  computation.call uri
               end
               Process.wait child
               DRb.stop_service
            end
         end
      end

   end

   # Set up multi processing 
   #
   # Initialize a CARPProcess object into the global variable $process
   def init_process
      $process = CARPProcess.new "process.yaml" 
   end

   # Set up multi-threading
   #
   # Can be called more than once
   def init_threading
      Thread.abort_on_exception = true
   end

end
