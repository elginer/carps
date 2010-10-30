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

require "carps/mod"

require "carps/ui"

module CARPS

   module DM
      # Class for DM mods
      #
      # Functions as a facade to the resource, mailer and reporter classes.
      #
      # Subclasses should override schema and semantic_verifier
      #
      # FIXME: This class is WAY too big
      class Mod < CARPS::Mod

         # Initialize with a resource manager, and a mailer 
         def initialize resource, mailer
            @mailer = mailer
            @resource = resource
            @reporter = Reporter.new
            @resource.reporter = @reporter
            @players = {}
            @npcs = {}
            @entities = {}
            @monikers = {}
            @mails = {}
         end

         # Invite a new player
         def invite addr
            @mailer.invite addr
         end

         # Save the game
         def save
            @mailer.save self
         end

         # Edit a sheet
         def edit_sheet name
            with_entity name,
               lambda {edit_player_sheet name},
               lambda {edit_npc_sheet name}
         end

         # Ask a question of the player
         def ask_player player
            with_player player do
               edit = Editor.load
               question = edit.edit "# Enter question for #{player}"
               @reporter.ask_player player, question
            end
         end

         # Ask a question of everyone
         def ask_everyone
            edit = Editor.load
            question = edit.edit "# Enter question for everyone"
            @players.each_key do |player|
               @reporter.ask_player player, question
            end
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
            @reporter.delete_reports
         end

         # Delete a player's report
         def delete_report player
            with_player player do
               @reporter.update_player player, ""
            end
         end

         # All players are in this room
         def everyone_in room
            @resource.players_in @players.keys, room
         end

         # A player is in this room
         def player_in player, room
            with_player player do
               @resource.player_in player, room
            end
         end

         # Create a new npc
         def new_npc type, name
            if moniker_available? name
               if char = @resource.new_npc(type)
                  char = editor.validate char 
                  @npcs[name] = char
                  @entities[name] = :npc
               end
            end
         end

         # Inspect all turns
         def inspect_reports
            turns = @reporter.player_turns @players.keys
            turns.each do |moniker, t|
               puts "Upcoming turn for " + moniker
               t.preview
            end
         end

         # Inspect a player's turn
         def inspect_turn player
            with_player player do
               turn = @reporter.player_turn player
               turn.preview
            end
         end

         # Next turn 
         def next_turn
            # Save the game
            save
            send_reports
            @reporter = Reporter.new
         end

         # Create a report that all players will see
         def create_global_report
            e = Editor.load
            global = e.edit "# Enter report for all players."
            @players.each_key do |player|
               puts "global: " + global
               @reporter.update_player player, global
            end
         end

         # Edit the report for a player 
         def tell player
            with_player player do
               @reporter.edit player
            end
         end

         # Add a player
         def add_player email
            valid = false
            until valid
               moniker = UI::question "Enter moniker for " + email
               valid = moniker_available? moniker
            end
            add_known_player moniker, email
         end

         # Add a player with a moniker
         def add_known_player moniker, email
            @monikers[moniker] = email
            @mails[email] = moniker
            @entities[moniker] = :player
         end

         # Describe an entity
         def describe name
            with_entity name,
               lambda {unsafe_describe_player name},
               lambda {unsafe_describe_npc name}
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

         # List all the players
         def list_players
            puts "The players are:"
            @players.each_key do |player|
               unsafe_describe_player player
            end
         end

         # Check for mail 
         def check_mail
            if mail = @mailer.check(Sheet::NewSheet)
               unless @mails.member? mail.from 
                  add_player mail.from
               end
               with_valid_mail mail do |moniker|
                  new_character_sheet moniker, Sheet::Character.new(mail.dump)
               end
            elsif mail = @mailer.check(Answers)
               with_valid_mail mail do |moniker|
                  new_answer moniker, mail
               end
            end

            if mail
               true
            else
               puts "No new mail."
               false
            end

         end

         protected

         # Perform an action with an entity,
         # where it does not matter if the entity is a player or an NPC.

         # Perform an action with an entity.
         #
         # The first Proc is called if it's a Player
         #
         # The second is called if it's an NPC
         def with_entity name, player_proc, npc_proc
            case @entities[name]
            when :player
               player_proc.call   
            when :npc
               npc_proc.call
            when nil
               UI::put_error "Unknown entity: #{name}"
            end
         end

         # Perform an action with an NPC's sheet.  Pass a block
         def with_npc_sheet name
            sheet = @npcs[name]
            sheet = yield sheet
            @npcs[name] = sheet
         end

         # Register a new character sheet
         def new_character_sheet moniker, sheet
            with_player_sheet moniker do |old_sheet|
               UI::highlight "New character sheet for #{moniker}"
               editor.validate sheet
            end
         end

         def unsafe_describe_npc npc
            puts @npcs[npc].emit
         end

         def unsafe_describe_player player
            mail = @monikers[player]
            puts mail + " aka " + player + " aka: "
            puts @players[player].emit
         end

         # Moniker is available?
         def moniker_available? mon
            not @entities.member? mon
         end

         # Send the reports
         def send_reports
            turns = @reporter.player_turns @players.keys
            turns.each do |moniker, turn|
               addr = @monikers[moniker]
               @mailer.relay addr, turn
            end
         end

         # Search for mail
         def search mail
            found = nil
            mail.each do |moniker, inbox|
               unless inbox.empty?
                  found = [moniker, inbox.shift]
                  break
               end
            end
            return found
         end

         # Print the answer
         def new_answer moniker, answer
            answer.from = moniker
            answer.display
         end

         def with_valid_mail mail
            moniker = @mails[mail.from]
            if moniker
               yield moniker
            else
               warn "BUG",  "Mod received mail from unregistered player #{mail.from}"
            end
         end

         # Perform an action that takes a players sheet and returns a new one.  Pass a block.
         def with_player_sheet name
            sheet = @players[name]
            sheet = yield sheet
            @players[name] = sheet
            @reporter.sheet name, sheet
         end

         # Edit a player's character sheet
         def edit_player_sheet name
            with_player_sheet name do |sheet|
               editor.fill sheet
            end
         end

         # Edit an npc's character sheet
         def edit_npc_sheet name
            with_npc_sheet name do |sheet|
               editor.fill sheet
            end
         end

         # If the player exists, continue
         def with_player player
            if player? player
               yield
            else
               UI::put_error "Unknown player."
            end
         end

         # Does a player exist?
         def player? player
            @players.member? player
         end

         # Only execute the block if the npc exists
         def with_npc name
            if @npcs.member? name
               yield
            else
               UI::put_error "Unknown NPC."
            end
         end

      end

   end

end
