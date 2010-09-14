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
require "mod/answers"
require "mod/character_sheet"

require "mod/dm/reporter"
require "mod/dm/character"

require "util/editor"

# Class for DM mods
#
# Subclasses should override
# interpreter, schema, semantic_verifier
class Mod

   # Initialize with a resource manager, and a mailer 
   def initialize resource, mailer
      @mailer = mailer
      @resource = resource
      @reporter = Reporter.new resource
      @monikers = {}
      @mails = {}
      @answers = {}
      @character_sheets = {}
      receive mail
   end

   # Receive mail
   def receive mail
      Thread.fork do
         loop do
            @mailer.read Answers
            sleep 1
         end
      end
      Thread.fork do
         loop do
            @mailer.read CharacterSheet
            sleep 1
         end
      end
   end

   # A new turn
   def next_turn
      @reporter.update_everyone ""
      @reporter.ask_everyone []
   end

   # Edit the report for a player 
   def edit player
      @reporter.edit player
   end

   # Add a player
   def add_player email
      moniker = question "Enter moniker for " + email
      @monikers[moniker] = email
      @mails[email] = moniker
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
      mail.reject! do |moniker, mail_list|
         mail_list.empty?   
      end
      if mail.empty?
         return nil
      else
         return mail.shift
      end
   end

   # Check for mail 
   def check_mail
      if mail = search(@character_sheets)
         new_character_sheet *mail
      elsif result = search(@answers)
         new_answer *mail
      else
         puts "No new mail."
      end
   end

   # Register a new character sheet
   def new_character_sheet moniker, sheet
      if sheet.verify schema
         if sheet.verify_semantics semantic_verifier
            Ch.create moniker, sheet
         end
      end
   end

   # The semantic verifier
   def semantic_verifier sheet
      NullVerifier.new
   end

   # Print the answer
   def new_answer moniker, answer
      answer.from = moniker
      answer.display
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

# Semantic verifier that always returns true
class NullVerifier
   def verify sheet
      true
   end
end
