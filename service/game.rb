require "service/mods.rb"
require "protocol/keywords.rb"
require "email/string.rb"

# A game 
class Game

   # The first parameter is email account information.
   # The second is the mod.
   # The third is the description.
   # The fourth is a list of email addresses of players to be invited
   def initialize account, mod, desc, players
      @dm = account.username
      @smtp = account.smtp
      @imap = account.imap
      @mod = mod
      @about = desc
      @players = players
   end

   # Print game information
   def display
      puts "Game master: " + @dm
      puts "Mod: " + @mod
      puts "Description:"
      puts @about
   end

   # Join this game as a client
   def join_game account
      mod = load_mods[mod]
      if mod
         require mod
         return Game.join(account)
      end
   end

   # Parse this from semi-structured text
   def Game.parse blob
      dm, blob = find carp_master, blob
      mod, blob = find carp_mod, blob
      about, blob = find carp_about, blob
      [Game.new(dm, mod, code, about), blob] 
   end

   # Emit this as semi-structured text
   def emit
      (carp_master @dm) + (carp_mod @mod) + (carp_about MailString.new @about)
   end
  
   # Invite players to this game
   def invite_players
      invite = Invite.new self 
      @players.each do |player|
         @smtp.send player, invite 
      end
   end 

end
