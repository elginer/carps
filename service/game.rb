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

require "service/mod"

require "protocol/keyword"

require "util/question"

require "util/process"

require "drb"

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
   def initialize mailer, mod, desc, players
      @dm = mailer.address 
      @mailer = mailer 
      @mod = mod
      @about = desc
      @players = players
   end

   # Invite players to this game
   def invite_players
      # Perform handshakes
      threads = @players.map do |player|
         # Handshakes are done asychronously
         @mailer.handshake player
      end
      threads.each do |thread|
         thread.join
      end
      invite = Invite.new @dm, self
      @players.each do |player|
         puts "Inviting #{player}"
         if $evil
            puts "Sending evil message..."
            @mailer.evil player, invite 
         else
            @mailer.send player, invite
         end
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

   # Expose the mod so the client decide if he can even think of joining
   def mod
      @mod
   end

   # Join this game as a client
   def join_game mailer
      mod = load_mods[@mod]
      if mod
         main = mod + "/" + "client.rb"
         $process.launch ModInfo.new(@dm, mailer), main
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

# An invitation
class Invite < Message

   # We are part of the protocol :)
   protoword "invite"

   def initialize from, game, delayed_crypt=nil
      @game = game
      super from, delayed_crypt
   end

   def Invite.parse from, blob, delayed_crypt
      forget, blob = find K.invite, blob
      info, blob = GameClient.parse blob
      [Invite.new(from, info, delayed_crypt), blob]
   end

   # Ask if the player wants to accept this invitation
   def ask
      puts "You have been invited to a game!"
      unless load_mods.member? @game.mod
         puts "But it's for the mod: " + @game.mod
         puts "Which you don't have installed."
         return false
      end
      @game.display
      confirm "Do you want to join?"
   end

   # Accept the invitation
   def accept account
      @game.join_game account
   end

   def emit 
      K.invite + @game.emit
   end

end
