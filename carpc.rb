require "email/config.rb"
require "util/error.rb"

# Wait for an invitation, and to see if it has been accepted by the user
def receive_invitation account
   # Do this until we break out of the loop
   # *sigh* it's just not haskell
   while true
      puts "\nWaiting for an invitation to a game... go phone the DM :p"
      message = account.imap.read :invite
      message.speak account
   end   
end

# Run the client 
def main
   # Get the client's email information
   account = EmailConfig.new "email.yaml", ClientParser.new
   # Wait for an invitation to a game
   game = receive_invitation account
end
