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

      # Create a new dice
      def d i
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

         # Roll the dice
         def roll
            od = []
            results = odds.to_a
            current = 0
            # Build up range arrays corresponding to probabalistic weights
            until results.empty?
               # Manually insert a 1 at the end to make this numerically stable
               last = false
               if results.length == 1
                  last = true
               end
               result, weight = results.shift
               if last
                  od.push [current..1, result]
               else
                  new_top = current + weight
                  od.push [current..new_top, result]
                  current = new_top
               end
            end
            # Find the appropriate action
            r = rand
            od.each do |range, result|
               if range.include? r
                  return result
               end
            end
            raise StandardError, "Dice has no result BUG!"
         end

         # Output the odds
         #
         # That is, a hash of results to the probabalistic weights of the possible results.
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

         # If the result matches a binary comparison, then return this result
         #
         # compare is one of :<, :<=, :==, :>, :>=
         #
         # other is an integer to compare with
         def is compare, other, output
            cmp = Dice::comparison_to_proc compare, other

            rng = find_range cmp
            if rng
               in_range rng, output
            end
         end

         protected

         # Find the Range of values which when applied to op give true
         #
         # If no results match the operator, return nil instead
         def find_range op
            results = @rolls.values.reject {|result| not op.call result}
            if results.empty?
               nil
            else
               results.min..results.max
            end
         end

         # Do an arithmetic operation with the results of another dice roll
         def with_dice_arithmetic other
            new_rolls = {}
            new_weights = {}
            # Compute the new weights
            @weights.keys.sort.reverse.each do |roll|
               other.weights.keys.each do |oroll|
                  weight = @weights[roll]
                  oweight = other.weights[oroll]
                  result = @rolls[roll]
                  oresult = other.rolls[oroll]
                  chance = weight * oweight
                  added_roll = roll + oroll
                  new_result = yield result, oresult
                  new_side = roll + oroll
                  if new_rolls.include? new_side
                     new_side = new_weights.keys.max + 1
                  end
                  new_weights[new_side] = chance
                  new_rolls[new_side] = new_result
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
            @rolls.to_a.each do |roll, result|
               if range.include? result
                  @rolls[roll] = output
               end
            end
         end

         # Update every result in this range to be the result of a dice roll
         def in_range_dice range, other
            new_rolls = other.rolls
            new_weights = {}
            affected_rolls = @rolls.reject {|roll, result| not range.include? result}
            affected_rolls.each_key do |roll|
               # Add roll to new_weights and new_rolls
               roll_again roll, other, new_rolls, new_weights
               @weights.delete roll
               @rolls.delete roll
            end
            # Invent new dice sides to cope with multiple roll values
            other.rolls.keys.each do |roll|
               if @weights.include? roll
                  weight = new_weights[roll]
                  result = new_rolls[roll]
                  new_weights.delete roll
                  new_rolls.delete roll
                  new_max = new_weights.keys.max
                  old_max = @weights.keys.max
                  new_side = [new_max, old_max].max + 1
                  new_weights[new_side] = weight
                  new_rolls[new_side] = result
               end
            end
            @weights.merge! new_weights
            @rolls.merge! new_rolls
         end

         # If this result is rolled, the result shall be given by the other dice
         def roll_again roll, other, new_rolls, new_weights
            weight = @weights[roll]
            other.weights.each do |onum, oweight|
               this_weight = weight * oweight
               if new_weights.include? onum
                  new_weights[onum] = new_weights[onum] + this_weight
               else
                  new_weights[onum] = this_weight
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

      # When compare is one of
      #
      # :<, :<=, :==, :>, :>=
      #
      # and other is an integer
      #
      # Return a proc which takes an argument a
      # and does
      #
      # a compare other
      def Dice::comparison_to_proc compare, other
         cmp = nil
         case compare
         when :<
            cmp = lambda {|a| a < other}
         when :<=
            cmp = lambda  {|a| a <= other}
         when :==
            cmp = lambda {|a| a == other}
         when :>=
            cmp = lambda {|a| a >= other}
         when :>
            cmp = lambda {|a| a > other}
         end
         cmp
      end

   end

end
