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

require "util/warn"

# Class for DM mods
#
# Subclasses should override
# interpreter, schema, semantic_verifier
class Mod

   # Initialize with a resource manager, and a mailer 
   def initialize resource, mailer
      @mailer = mailer
      @resource = resource
      @reporter = Reporter.new
      @monikers = {}
      @mails = {}
      @answers = {}
      @character_sheets = {}
      @semaphore = Mutex.new
      receive
   end



   # Inspect reports
   def inspect_reports
      turns = @reporter.player_turns
      turns.each do |moniker, t|
         puts "Upcoming turn for " + moniker
         t.preview
      end
   end

   # Send the reports
   def send_reports
      turns = @reporter.player_turns
      turns.each do |moniker, t|
         addr = @monikers[moniker]
         @mailer.send addr, t
      end
   end

   # Next turn 
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
      new_player moniker, email
   end

   # Add a player with a moniker
   def add_known_player moniker, email
      @reporter.add_player moniker
      @monikers[moniker] = email
      @mails[email] = moniker
      @character_sheets[moniker] = []
      @answers[moniker] = []
      request_character_sheet moniker
   end

   # List all the players
   def list_players
      puts "The players are:"
      @monikers.each do |player, mail|
         puts mail + " aka " + player
      end
   end

   # Search for mail
   def search mail
      found = nil
      @semaphore.synchronize do
         mail.each do |moniker, inbox|
            unless inbox.empty?
               found = [moniker, inbox.shift]
               break
            end
         end
      end
      return found
   end

   # Check for mail 
   def check_mail
      if mail = search(@character_sheets)
         new_character_sheet *mail
         return true
      elsif result = search(@answers)
         new_answer *mail
         return true
      else
         puts "No new mail."
         return false
      end
   end

   # Register a new character sheet
   def new_character_sheet moniker, sheet
      unless sheet.syntax_error schema
         if sheet.verify_semantics semantic_verifier
            Ch.create moniker, sheet
         end
      end
   end

   # The semantic verifier
   def semantic_verifier
      NullVerifier.new
   end

   # Print the answer
   def new_answer moniker, answer
      answer.from = moniker
      answer.display
   end

   # Request a character sheet from the player
   def request_character_sheet moniker
      email = @monikers[moniker]
      @mailer.send email, CharacterSheetRequest.new(schema)
   end

   private

   # Receive mail
   def receive
      receive_mails Answers, @answers
      receive_mails CharacterSheet, @character_sheets
   end

   def receive_mails klass, hash
      Thread.fork do
         loop do
            mail = @mailer.read klass
            moniker = @mails[mail.from]
            @semaphore.synchronize do
               inbox = hash[moniker]
               if inbox
                  inbox.push mail
               else
                  warn "Unwanted email from #{mail.from}"
               end
            end
            sleep 1
         end
      end
   end

end

# Semantic verifier that always returns true
class NullVerifier
   def verify sheet
      true
   end
end
