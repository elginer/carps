require "email/config.rb"
require "util/error.rb"

# Wait for an invitation, and to see if it has been accepted by the user
def receive_invitation account
   # Do this until we break out of the loop
   # *sigh* it's just not haskell
   while true
      puts "\nWaiting for an invitation to a game... go phone the DM :p"
      message = account.imap.read
      if message.type == :invite
         game_info = message.game_info
         puts "You have been invited to a game:"
         game_info.display
         puts "Do you want to join? (Type anything beginning with y to join)"
         join = gets
         if join[0] == "y"
            game_info.join_game account
         end
      end
   end   
end

# Run the client 
def main
   # Get the client's email information
   account = EmailConfig.new "email.yaml", ClientParser, ClientMessage
   # Wait for an invitation to a game
   game = receive_invitation account
end
