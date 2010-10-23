Feature: rules
   As a CARPS mod writer,
   in order to efficiently encode game rules,
   I need a high level interface to non-determinism.
   IE, show me the dice!

   Scenario: one dice 
      Given a d10
      Then show the odds

   Scenario: one dice and multiplication
      Given a d10
      Then multiply by 3
      Then show the odds

   Scenario: one dice and addition
      Given a d10
      Then add 5
      Then show the odds

   Scenario: one dice, multiplication and addition 
      Given a d10
      Then multiply by 3
      Then add 5
      Then show the odds
      
   Scenario: one dice and division
      Given a d10
      Then divide by 2
      Then show the odds

   Scenario: one dice and range analysis
      Given a d10
      Then if it's greater or equal to 3, and less than or equal to 7, the result is 0
      Then show the odds

   Scenario: two dice and addition
      Given a d2
      Then add a d4
      Then show the odds

   Scenario: two dice and multiplication
      Given a d3
      Then multiply by a d2
      Then show the odds

   Scenario: two dice and division
      Given a d3
      Then divide by a d2
      Then show the odds

   Scenario: two dice and range analysis
      Given a d3
      Then if it's greater or equal to 1, and less than or equal to 2, the result is a d4
      Then show the odds
