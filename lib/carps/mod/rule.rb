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

module CARPS

   # A rule.
   #
   # This class uses the TemplateMethod pattern.
   #
   # Subclasses should provide the following methods
   #
   # * 'dice' method which takes needed parameters (ie from apply and show_odds) and returns a Dice
   #
   # * actions which returns an array of pairs of integer ranges to Actions.  The actions should have an apply method which takes the needed parameters.  The idea is to associate the result of a dice roll with an action.
   class Rule

      # Apply the rule to the arguments
      def apply *args
         d = dice *args
         result = d.roll
         action_klass = choose_action_class result
         action = action_klass.new
         action.apply result, *args
      end

      # Print the odds
      def show_odds *args
         d = dice *args
         odds = {}
         d.odds.each do |result, chance|
            action = choose_action_class result
            odds[action] = odds[action].to_f + chance
         end
         puts "The odds are approximately:"
         puts "\n"
         # Sort the odds
         odds = odds.to_a.sort {|oda, odb| oda[1] <=> odb[1]}
         odds = odds.reverse
         odds.each do |action_klass, chance|
            action = action_klass.new
            percent = (chance * 100.0).to_i
            puts "#{percent}% chance:"
            puts "\t#{action.summary}"
         end
      end

      protected

      # Choose the action
      def choose_action_class result
         actions.each do |range, action|
            if range.include? result
               return action
            end
         end
         raise StandardError, "No action chosen BUG!"
      end


   end

end
