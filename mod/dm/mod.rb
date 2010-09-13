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

require "mod/character_sheet_request"

# Class for DM mods
class Mod

   def initialize
      @monikers = {}
      @answers = {}
      @character_sheets = {}
   end

   # Add a player
   def add_player email
      moniker = question "Enter moniker for " + email
      @monikers[moniker] = email
      request_character_sheet moniker, email
   end

   # List all the players
   def list_players
      puts "The players are:"
      @monikers.each do |player, mail|
         puts mail + " aka " + player
      end
   end

   # Search for mail
   #
   # Not re-entrant
   def search mail
      mail.each do |moniker, mail_list|
         if mail_list.empty?
            mail.delete moniker
         else
            return mail_list.shift
         end
      end
   end

   # Wait upon the next mail and then act upon it 
   def wait_for_mail
      if mail = search(@character_sheets)
         new_character_sheet mail
      elsif mail = search(@answers)
         new_answer mail
      else
         puts "No new mail."
      end
   end

   # Request a character sheet from the player
   def request_character_sheet moniker, email
      send email, CharacterSheetRequest.new(blank_character_sheet)
   end

   # Set the gateway
   def gateway= gate
      @gateway = gate
   end

end
