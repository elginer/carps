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
require "mod/question"

require "mod/dm/reporter"
require "mod/dm/character"

require "util/warn"

# Class for DM mods
#
# Functions as a facade to the resource, mailer and reporter classes.
#
# Subclasses should override
# interpreter, schema, semantic_verifier
class Mod

   # Initialize with a resource manager, and a mailer 
   def initialize resource, mailer
      @mailer = mailer
      @resource = resource
      @resource.reporter = resource
      @reporter = Reporter.new
      @monikers = {}
      @mails = {}
      @answers = {}
      @character_sheets = {}
      @semaphore = Mutex.new
      receive
   end

   # If the player exists, continue
   def with_player player
      if player? player
         yield
      else
         puts "No player exists with that name."
      end
   end

   # Does a player exist?
   def player? player
      @monikers.member? player
   end

   # Ask a question of the player
   def ask_player player, question
      with_player player do
         @reporter.ask_player player, question
      end
   end

   # Ask a question of everyone
   def ask_everyone question
      @reporter.ask_everyone question
   end

   # Delete questions for a player
   def delete_questions player
      with_player player do
         @reporter.delete_questions player
      end
   end

   # Delete all questions
   def delete_all_questions
      @reporter.delete_all_questions
   end

   # Delete all reports
   def delete_all_reports
      @reporter.update_everyone ""
   end

   # Delete a player's report
   def delete_report player
      with_player player do
         @reporter.update_player player, ""
      end
   end

   # All players are in this room
   def everyone_in room
      @resource.everyone_in room
   end

   # A player is in this room
   def player_in player, room
      with_player player do
         @resource.player_in player, room
      end
   end

   # Create a new npc
   def new_npc type, name
      if npc = @resource.new_npc(type)
         npc_namespace.create name, npc
         @npcs.add name
      end
   end

   # Inspect all turns
   def inspect_reports
      turns = @reporter.player_turns
      turns.each do |moniker, t|
         puts "Upcoming turn for " + moniker
         t.preview
      end
   end

   # Inspect a player's turn
   def inspect_turn player
      with_player player do
         turn = @reporter.player_turn player
         t.preview
      end
   end

   # Next turn 
   def next_turn
      send_reports
      @reporter.update_everyone ""
      @reporter.ask_everyone []
   end

   # Edit the report for a player 
   def edit player
      with_player player do
         @reporter.edit player
      end
   end

   # Add a player
   def add_player email
      moniker = question "Enter moniker for " + email
      add_know_player moniker, email
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
            player_namespace.create moniker, sheet.dump
         end
      end
   end

   protected

   # Send the reports
   def send_reports
      turns = @reporter.player_turns
      turns.each do |moniker, t|
         addr = @monikers[moniker]
         @mailer.send addr, t
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

   # The semantic verifier
   def semantic_verifier
      NullVerifier.new
   end

   def player_namespace
      PC
   end

   def npc_namespace
      NPC
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
            puts "You have mail.  Go read it!"
            puts "\a"
            moniker = @mails[mail.from]
            @semaphore.synchronize do
               inbox = hash[moniker]
               if inbox
                  inbox.push mail
               else
                  warn "BUG:  Unwanted email from #{mail.from}.  However, this should have been handled in another part of the program..."
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
