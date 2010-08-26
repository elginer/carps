require "service/mods.rb"
require "protocol/keywords.rb"
require "email/string.rb"

# A game
# Subclasses must write the variables @dm, @mod, @about in their constructors
class Game

   # We add a few things to the protocol
   protoval "master"

   protoval "mod"

   protoval "about"

   # Print game information
   def display
      puts "Game master: " + @dm
      puts "Mod: " + @mod
      puts "Description:"
      puts @about
   end

   # Emit this as semi-structured text
   def emit
      (V.master @dm) + (V.mod @mod) + (V.about @about)
   end  
end

# Server game
class GameServer < Game

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

   # Invite players to this game
   def invite_players
      invite = Invite.new self 
      @players.each do |player|
         @smtp.send player, invite 
      end
   end 

end

# Client games
class GameClient < Game

   # The first parameter is the dungeon master's name
   # The second is the mod.
   # The third is the description.
   def initialize dm, mod, desc
      @dm = dm
      @mod = mod
      @about = desc
   end

   # Join this game as a client
   def join_game account
      mod = load_mods[@mod]
      if mod
         require mod
         return Mod.join(account)
      end
   end

   # Parse this from semi-structured text
   def GameClient.parse blob
      dm, blob = find K.master, blob
      mod, blob = find K.mod, blob
      about, blob = find K.about, blob
      [GameClient.new(dm, mod, about), blob] 
   end
end
