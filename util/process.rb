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

require "util/config"

require "drb"
require "drb/acl"

require "set"

# Responsible for launching other CARP processes
class CARPProcess < YamlConfig
   def parse_yaml conf
      ruby = read_conf conf, "launch_ruby"
      term = read_conf conf, "launch_terminal"
      start_port = read_conf(conf, "start_port").to_i
      end_port = read_conf(conf, "end_port").to_i
      port_range = start_port .. end_port
      [ruby, term, port_range]
   end

   def load_resources ruby, term, ports
      @ports = ports
      @ruby = ruby
      @term = term
      @used = Set.new
      @semaphore = Mutex.new
   end

   # Launch a ruby program in another terminal window, which can access the resource over drb
   def launch resource, program
      cmd = @term.gsub "%ruby", @ruby 
      ashare resource, lambda { |uri|
         program = "'" + program + "' '" + uri + "'"
         cmd = cmd.gsub "%args", program
         puts "Launching: #{cmd}"
         exec cmd 
      }
   end

   # May deadlock!
   def with_uri
      uri = "druby://localhost:"
      port = nil
      until port
         @semaphore.synchronize do
            @ports.each do |p|
               unless @used.member? p
                  @used.add p
                  port = p
                  break
               end
            end
         end
      end
      yield uri + port.to_s
      @semaphore.synchronize do
         @used.delete port
      end
   end

   # Run computation in the second argument in a new process allowing access the first
   def ashare resource, computation
      local_only = ACL.new %w[deny all allow localhost]
      DRb.install_acl local_only
      with_uri do |uri|   
         DRb.start_service(uri, resource).uri
         child = fork do
            DRb.start_service
            computation.call uri
            exit
         end
         Process.wait child
         DRb.stop_service
      end
   end
end

# Set up threading
#
# Initialize a CARPProcess object into the global variable $process
def init_process file
   Thread.abort_on_exception = true
   $process = CARPProcess.new file
end
