Feature: rules
   As a CARPS mod writer,
   in order to efficiently encode game rules,
   I need a high level interface to non-determinism.
   IE, show me the dice!

   Scenario: one dice 
      Given a d3
      Then show the odds
      Then each of the odds must be 1 / 3
      Then result 0 must be 1
      Then result 1 must be 2
      Then result 2 must be 3

   Scenario: one dice and multiplication
      Given a d3
      Then multiply by 3
      Then show the odds
      Then each of the odds must be 1 / 3
      Then result 0 must be 3
      Then result 1 must be 6
      Then result 2 must be 9

   Scenario: one dice and addition
      Given a d3
      Then add 5
      Then show the odds
      Then each of the odds must be 1 / 3
      Then result 0 must be 6
      Then result 1 must be 7
      Then result 2 must be 8

   Scenario: one dice, fractional multiplication
      Given a d6
      Then multiply by 1 / 2
      Then show the odds
      Then result 0 must be 0
      Then result 1 must be 1
      Then result 2 must be 2
      Then result 3 must be 3
      Then odd 0 must be 1 / 6
      Then odd 1 must be 1 / 3
      Then odd 2 must be 1 / 3
      Then odd 3 must be 1 / 6

   Scenario: one dice, multiplication and addition 
      Given a d3
      Then multiply by 3
      Then add 5
      Then show the odds
      Then each of the odds must be 1 / 3
      Then result 0 must be 8
      Then result 1 must be 11
      Then result 2 must be 14

   Scenario: one dice and division
      Given a d3
      Then divide by 2
      Then show the odds
      Then odd 0 must be 1 / 3
      Then odd 1 must be 2 / 3
      Then result 0 must be 0
      Then result 1 must be 1

   Scenario: one dice and range analysis
      Given a d3
      Then if it's greater or equal to 1, and less than or equal to 2, the result is 0
      Then show the odds
      Then odd 0 must be 2 / 3
      Then odd 1 must be 1 / 3

   Scenario: two dice and addition
      Given a d2
      Then add a d3
      Then show the odds
      Then odd 0 must be 1 / 6
      Then odd 1 must be 1 / 3
      Then odd 2 must be 1 / 3
      Then odd 3 must be 1 / 6
      Then result 0 must be 2
      Then result 1 must be 3
      Then result 2 must be 4
      Then result 3 must be 5

   Scenario: two dice and subtraction
      Given a d2
      Then subtract a d3
      Then show the odds
      Then result 0 must be -2
      Then result 1 must be -1
      Then result 2 must be 0
      Then result 3 must be 1
      Then odd 0 must be 1 / 6
      Then odd 1 must be 1 / 3
      Then odd 2 must be 1 / 3
      Then odd 3 must be 1 / 6


   Scenario: two dice and multiplication
      Given a d3
      Then multiply by a d2
      Then show the odds
      Then odd 0 must be 1 / 6
      Then odd 1 must be 1 / 3
      Then odd 2 must be 1 / 6
      Then odd 3 must be 1 / 6
      Then odd 4 must be 1 / 6
      Then result 0 must be 1
      Then result 1 must be 2
      Then result 2 must be 3
      Then result 3 must be 4
      Then result 4 must be 6

   Scenario: two dice and division
      Given a d3
      Then divide by a d2
      Then show the odds
      Then odd 0 must be 1 / 6
      Then odd 1 must be 1 / 2
      Then odd 2 must be 1 / 6
      Then odd 3 must be 1 / 6
      Then result 0 must be 0
      Then result 1 must be 1
      Then result 2 must be 2
      Then result 3 must be 3

   Scenario: two dice and range analysis
      Given a d3
      Then if it's greater or equal to 1, and less than or equal to 2, the result is a d4
      Then show the odds
      Then result 0 must be 1
      Then result 1 must be 2
      Then result 2 must be 3
      Then result 3 must be 4
      Then odd 0 must be 1 / 6
      Then odd 1 must be 1 / 6
      Then odd 2 must be 1 / 2
      Then odd 3 must be 1 / 6

   Scenario: two dice, uneven weights and range analysis
      Given a d4
      Then multiply by 2
      Then if it's greater or equal to 2, and less than or equal to 2, the result is a d4
      Then show the odds
      Then result 0 must be 1
      Then result 1 must be 2
      Then result 2 must be 3
      Then result 3 must be 4
      Then result 4 must be 6
      Then result 5 must be 8
      Then odd 0 must be 1 / 16
      Then odd 1 must be 1 / 16
      Then odd 2 must be 1 / 16
      Then odd 3 must be 5 / 16
      Then odd 4 must be 1 / 4
      Then odd 5 must be 1 / 4

   Scenario: binary comparison
      Given a d5
      Then if it's greater than 3, the result is 4
      Then show the odds
      Then result 0 must be 1
      Then result 1 must be 2
      Then result 2 must be 3
      Then result 3 must be 4
      Then odd 0 must be 1 / 5
      Then odd 1 must be 1 / 5
      Then odd 2 must be 1 / 5
      Then odd 3 must be 2 / 5

   Scenario: roll dice
      Given a d4
      Then roll the dice
