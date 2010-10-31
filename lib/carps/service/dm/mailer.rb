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

require "carps/service"

module CARPS

   module DM

      # A bridge between the DM mod and CARPS 
      class Mailer < ModMailer

         # Create the mailer from
         #
         # a Mailer,
         #
         # a GameConfig,
         # 
         # a session id,
         #
         # the email address of the dm,
         #
         # the name of the mod,
         #
         # and the description of the game
         def initialize mailer, conf, session, dm, mod, desc
            super mailer, conf
            @session = session
            @dm = dm
            @mod = mod
            @about = desc
         end

         # Invite a new player
         def invite addr
            inv = Invite.new @dm, @mod, @about, @session
            relay addr, inv
         end


         # Check for mail of a given type
         def check type
            @mailer.check type
         end

         # Send mail to the recipient
         def relay to, message
            @mailer.send to, message
         end

      end

   end

end
