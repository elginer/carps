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

require "drb"

# Load the available mods 
def load_mods
   mod_list = (Dir.open "mods").entries.reject do |filename|
      filename[0] == "." and File.ftype(filename) == "directory"
   end
   mods = {} 
   mod_list.each do |mod_name|
      mods[mod_name] = "mods/" + mod_name
   end
   mods
end

# Information to be provided as a drb service to the client portion of a mod
ModInfo = Struct.new :mailer, :dm

# Interface for the server portion of a mod
class ServerInterface

   include DRbUndumped

   # Create the server interface from a cryptographic mailer
   def initialize mailer
      @mailer = mailer
      @accepted = []
      @semaphore = Mutex.new
      await_acceptance
   end

   # Await acceptances and pass them to the mod
   def await_acceptance
      Thread.fork do
         until @mod
            sleep 1
         end
         loop do
            @semaphore.synchronize do
               @accepted.each do |a|
                  @mod.acceptance a
               end
               @accepted = []
            end
            sleep 1
         end
      end
   end

   # Read a mail
   def read type, from = nil
      @mailer.read type, from
   end

   # Send a mail
   def send to, message
      @mailer.send to, message
   end

   # The mod will register itself with the interface
   #
   # It can then be informed of players accepting invitations
   def mod_observer mod
      @mod = mod
   end

   # Takes an AcceptInvitation message, and passes it to the mod
   def acceptance message
      @semaphore.synchronize do
         @accepted.push message
      end
   end
end

# Register the name of this mod so it can require its own files
def this_mod mod
    $LOAD_PATH.push "./mods/" + mod + "/"
end
