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

# Responsible for launching other CARP processes
class CARPProcess < YamlConfig
   def parse_yaml conf
      ruby = read_conf conf, "launch_ruby"
      term = read_conf conf, "launch_terminal"
      [ruby, term]
   end

   def load_resources ruby, term
      @ruby = ruby
      @term = term
   end

   # Launch a ruby program in another terminal window, which can access the resource over drb
   def launch resource, program
      share_with resource, @term + " " + @ruby + " " + program
   end

end

# Spawn a process with the second argument that can access the first.
def share_exec resource, program
   share resource, lambda do |uri|
      exec program + " " + uri
   end
end

$ashare_semaphore = Mutex.new
$ashare_port = 9000
# Run computation in the second argument in a new process allowing access the first
def ashare resource, computation
   local_only = ACL.new %w[deny all allow localhost]
   DRb.install_acl local_only
   $ashare_semaphore.synchronize do
      if $ashare_port < 9100
         $ashare_port = $ashare_port + 1
      else
         $ashare_port = 9000
      end
   end
   uri = "druby://localhost:" + $ashare_port.to_s
   DRb.start_service(uri, resource).uri
   child = fork do
      DRb.start_service
      computation.call uri
      exit
   end
   Process.wait child
   DRb.stop_service
end
