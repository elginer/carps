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


require "email/config"

require "service/client_parser"

# Wait for an invitation, and to see if it has been accepted by the user
def receive_invitation mailer 
   # Do this until we have accepted an invite
   accepted = nil
   until accepted
      puts "\nWaiting for an invitation to a game... go phone the DM :p"
      invite = mailer.read :invite
      if invite.ask
         accepted = invite
      end
   end
   accepted 
end

# Run the client 
def main
   # Get the client's email information
   account = EmailConfig.new "email.yaml", client_parser
   # Get the mailer
   mailer = account.mailer ClientMailer
   # Wait for a handshake
   mailer.expect_handshake
   # Wait for an invitation to a game
   invite = receive_invitation mailer
end
