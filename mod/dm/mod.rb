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
require "mod/sheet_verifier"
require "mod/sheet_editor"
require "mod/question"

require "mod/dm/reporter"
require "mod/dm/character"

require "util/warn"

# Class for DM mods
#
# Functions as a facade to the resource, mailer and reporter classes.
#
# Subclasses should override
# schema, semantic_verifier
class Mod

   # Initialize with a resource manager, and a mailer 
   def initialize resource, mailer
      @mailer = mailer
      @resource = resource
      @resource.reporter = resource
      @reporter = Reporter.new
      @players = {}
      @npcs = {}
      @monikers = {}
      @mails = {}
      @answers = {}
      @character_sheets = {}
      @semaphore = Mutex.new
      receive
   end

   # Edit a player's character sheet
   def edit_player_sheet name
      with_player name do
         sheet = @players[name]
         editor = SheetEditor.new schema, semantic_verifier
         @players[name] = editor.fill sheet.dump
      end
   end

   # Edit an npc's character sheet
   def edit_npc_sheet name
      with_npc name do
         sheet = @npcs[name]
         editor = SheetEditor.new schema, semantic_verifier
         @npcs[name] = editor.fill sheet.dump
      end
   end

   # If the player exists, continue
   def with_player player
      if player? player
         yield
      else
         put_error "Unknown player."
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

   # Update a player's report
   def update_player player, report
      @reporter.update_player player, report
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
      if char = @resource.new_npc(type, schema, semantic_verifier)
         validator = SheetEditor.new schema, semantics
         if validator.valid? CharacterSheet.new(char)
            @npcs[name] = npc.new char
         end
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
      add_known_player moniker, email
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

   # Only execute the block if the npc exists
   def with_npc name
      if @npcs.member? name
         yield
      else
         put_error "Unknown NPC."
      end
   end

   # Describe npc
   def describe_npc npc
      with_npc npc do
         unsafe_describe_npc npc
      end
   end

   def unsafe_describe_npc npc
      puts @npcs[npc].emit
   end

   # Describe all npcs
   def list_npcs
      puts "The NPCs are:"
      @npcs.each_key do |npc|
         puts "\n#{npc}:"
         unsafe_describe_npc npc
      end
   end


   # Return player stats
   def player_stats player
      @players[player]
   end

   # Return npc stats
   def npc_stats npc
      @npcs[npc]
   end

   # Describe a player
   def describe_player player
      with_player player do
         unsafe_describe_player player
      end
   end

   def unsafe_describe_player player
      mail = @monikers[player]
      puts mail + " aka " + player + " aka: "
      puts @players[player].emit
   end

   # List all the players
   def list_players
      puts "The players are:"
      @players.each_key do |player|
         unsafe_describe_player player
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
      sheet_editor = SheetEditor.new schema, semantic_verifier
      unless sheet_editor.valid?(sheet)
         sheet = sheet_editor.fill sheet.dump
      end
      @players[moniker] = player.new sheet.dump
   end

   protected

   def player
      Character
   end

   def npc
      Character
   end

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
            puts "You have mail from #{mail.from} aka #{moniker}.  Go read it!"
            puts "\a"
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
