#! /usr/bin/ruby1.9.1

require "email/config.rb"

# Get the player to choose which mod we are to play
def choose_mod
   mods = (Dir.open "mods").entries.reject do |filename|
      filename[0] == "."
   end
   if mods.length > 1
      puts "Available mods:"
      mods.each_index do |mod_index|
         puts "#{mods[mod_index]}, mod number #{mod_index}"
      end
      puts "Enter the number of the mod you wish to play"
      return mods[gets]
   elsif mods.length == 1
      mod = mods[0]
      puts "The only mod available is #{mod}.  Not much choice..."
      return mod
   else
      puts "No mods are available.  Try installing one first..."
      exit
   end
end

# Wait for an invitation, and to see if it has been accepted by the user
def receive_invitation account, mod
   # Do this until we break out of the loop
   # *sigh* it's just not haskell
   while true 
      email = account.imap.read
      subject_matches = /Invitation #{mod} (.+)/.match email.subject
      if subject_matches != nil
         dm = email.address
         code = subject_matches[1]
         puts "You have been invited to a game hosted by #{dm}"
         puts "Running #{mod}"
         puts "Its game number is: #{code}"
         puts "Do you want to join? (Type anything beginning with y to join)"
         join = gets
         if join[0] == "y"
            return Game.new mod, dm, code, account
         end
      end
   end   
end

# Run the client
def main
   # Get the player to choose the mod we're going to run
   mod = choose_mod
   # Get the client's email information
   account = EmailConfig.new
   # Wait for an invitation to a game
   game = receive_invitation account, mod
end


# Run the client program
main
