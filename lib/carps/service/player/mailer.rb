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

require "carps/service/start/mailer"

module CARPS

   module Player

      # A bridge between the Player mod and CARPS 
      class Mailer < ModMailer

         # Create from the email address of the dungeon master,
         # a mailer,
         # and a configuration file
         def initialize dm, mailer, conf
            @dm = dm
            super mailer, conf
         end

         # Check for mail from the dm
         def check type
            @mailer.check type, @dm
         end

         # Send mail to the dm
         def relay message
            @mailer.send @dm, message
         end

      end

   end

end
