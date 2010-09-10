Feature: DM interface
   The DM requires a powerful interface
   To communicate with the players

   Scenario: describe room
      Given a room
      Then describe the room to the players

   Scenario: moniker
      Given an email address for player 0
      Then associate player 0's email address with a moniker

   Scenario: customize report
      Given a room
      Given a reporter
      Given an email address for player 0
      Then associate player 0's email address with a moniker 
      Given an email address for player 1
      Then associate player 1's email address with a moniker
      Then customize report
      Then describe the room to each player 
