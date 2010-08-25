require "service/mods.rb"
require "protocol/keywords.rb"
require "email/string.rb"

# Game information
class GameInfo

   # The first parameter is the dungeon master,
   # the second is the mod
   # the third is the game code
   # the fourth is the description
   def initialize dm, mod, code, desc
      @dm = dm
      @mod = mod
      @code = code
      @about = desc
   end

   # Print game information
   def display
      puts "Game master: " + @dm
      puts "Mod: " + @mod
      puts "Code: " + @code
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
   def GameInfo.parse blob
      dm, blob = find carp_master, blob
      mod, blob = find carp_mod, blob
      code, blob = find carp_code, blob
      about, blob = find carp_about, blob
      [GameInfo.new(dm, mod, code, about), blob] 
   end

   # Emit this as semi-structured text
   def emit
      carp_master @dm + carp_mod @mod + carp_code @code + carp_about MailString.new @about
   end
   

end
