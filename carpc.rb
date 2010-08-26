require "email/config.rb"
require "util/error.rb"

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
   account = EmailConfig.new "email.yaml", ClientParser.new
   # Get the mailer
   mailer = account.mailer
   # Wait for an invitation to a game
   invite = receive_invitation mailer
   # Accept the invitation
   invite.accept account
end
