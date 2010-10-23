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

   module Dice

      # Random integer between min and max
      def Dice::rint min, max
         rfloat(min - 0.5, max + 0.5).round
      end

      # Random floating point number between min and max
      def Dice::rfloat min, max
         diff = max - min
         r = rand * diff
         r + min
      end

   end

   # Create a new dice
   def Dice::d i
      D.new i
   end

   # A dice
   #
   # Note that the methods here - including +, *, etc - update the dice's internal state, and do not return a new dice.
   class D

      # Create the dice from an integer, the number of sides
      #
      # The dice will have sides numbered from 1 to i.
      def initialize i
         @rolls = {}
         @weights = {}
         fair_weight = 1.0 / i
         i.times do |n|
            n = n + 1
            @rolls[n] = n
            @weights[n] = 1.0 / i
         end
      end

      # Output the odds
      def odds
         od = {}
         @weights.each do |roll, weight|
            result = @rolls[roll]
            if od.include? result
               od[result] = od[result] + weight
            else
               od[result] = weight
            end
         end
         od
      end

      # Output the weights table
      def weights
         @weights
      end

      # Output the roll table
      def rolls
         @rolls
      end

      # Add a number or another dice
      def + other
         if is_int other
            add_int other
         else
            add_dice other
         end
      end

      # Subtract a number or another dice
      def - other
         if is_int other
            add_int (other * -1)
         else
            add_dice other
         end
      end

      # Multiply by a number or another dice
      def * other
         if is_int other
            mul_int other
         else
            mul_dice other
         end
      end

      # Divide by a number or another dice
      def / other
         if is_int other
            div_int other
         else
            div_dice other
         end
      end

      # Directly inspect the range and supply a number or a dice as output, if the result is in that range
      def in_range range, output
         if is_int output
            in_range_int range, output
         else
            in_range_dice range, output
         end
      end

      protected

      # Do an arithmetic operation with the results of another dice roll
      def with_dice_arithmetic other
         new_rolls = {}
         new_weights = {}
         # Compute the new weights
         @weights.each do |roll, weight|
            other.weights.each do |oroll, oweight|
               chance = weight * oweight
               added_roll = roll + oroll
               if new_weights.include? added_roll
                  new_weights[added_roll] = new_weights[added_roll] + chance
               else
                  new_weights[added_roll] = chance
               end
            end
         end
         # Compute the new values
         @rolls.each do |roll, result|
            other.rolls.each do |oroll, oresult|
               new_result = yield result, oresult
               added_roll = roll + oroll
               unless new_rolls.include? added_roll
                  new_rolls[added_roll] = new_result
               end
            end
         end
         @rolls = new_rolls
         @weights = new_weights
      end

      # Add a dice
      def add_dice other
         with_dice_arithmetic other do |my, their|
            my + their
         end
      end

      # Multiply by the result of a dice roll
      def mul_dice other
         with_dice_arithmetic other do |my, their|
            my * their
         end
      end

      # Divide by the result of a dice roll
      def div_dice other
         with_dice_arithmetic other do |my, their|
            my / their
         end
      end

      # Is this an integer?
      def is_int i
         i.class == Fixnum
      end

      # Update every result in this range
      def in_range_int range, output
         @rolls.each_key do |roll|
            if range.include? roll
               @rolls[roll] = output
            end
         end
      end

      # Update every result in this range to be the result of a dice roll
      def in_range_dice range, other
         new_rolls = {}
         new_weights = {}
         range.to_a.each do |roll|
            roll_again roll, other, new_rolls, new_weights
         end
         @weights.merge new_weights
         @rolls.merge new_rolls
      end

      # If this number is rolled, the result shall be given by the other dice
      def roll_again roll, other, new_rolls, new_weights
         weight = @weights[roll]
         other.weights.each do |onum, oweight|
            this_weight = weight * oweight
            if new_weights.include? onum
               new_weights[onum] = new_weights[onum] + this_weight
            else
               new_weights[onum] = oweight + this_weight
            end
         end
      end

      # Add an integer to the results
      def add_int n
         on_results do |odd|
            n + odd
         end
      end

      # Multiply results by the integer
      def mul_int n
         on_results do |odd|
            n * odd
         end
      end

      # Divide results by the integer
      def div_int n
         on_results do |odd|
            odd / n
         end
      end

      # Perform an operation on the results
      def on_results
         @rolls.each do |roll, result|
            @rolls[roll] = yield result
         end
      end

   end

end
