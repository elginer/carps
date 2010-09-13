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

require "mod/question"
require "mod/client_turn"
require "mod/status_report"
require "mod/resource"

require "util/edit"
require "util/question"

# Used by the dungeon master to generate reports
#
# Subclasses must provide "player_turn" method
#
# which takes a monikers (a string used to identify a player)
#
# and producees a ClientTurn object for that player
class Reporter

   # Takes a resource manager
   def initialize resource
      resource.reporter = self
      @status = {}
      @monikers = {}
      @questions = []
   end

   # Add a player
   def add_player email
      moniker = question "Enter moniker for " + email
      @monikers[moniker] = email
   end

   # Produce a ClientTurn for the player referred to by the moniker
   def player_turn moniker
      status = StatusReport.new @status[moniker]
      ClientTurn.new status, @questions
   end

   # Take a hash of monikers to email addresses
   #
   # Produce a hash of email address to ClientTurn objects
   def player_turns
      turns = {}
      @monikers.each do |moniker, mail|
         turns[mail] = player_turn moniker 
      end
      turns
   end

   # Edit the report for a player 
   def edit player, editor
      @status[player] = editor.edit @status[player]
   end

   # Used by the resource manager to inform the reporter of updates to a player's status report
   def update_player_status player, status
      @status[player] = status
   end

   # Used by the resource manager to inform the reporter of updates to everyone's status
   def update_global_status status
      @monikers.each_key do |moniker|
         @status[moniker] = status
      end
   end

end
