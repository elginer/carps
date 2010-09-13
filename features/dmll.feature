Feature: DM interface components
   The DM requires a powerful interface
   To communicate with the players

   Scenario: produce reports
      Given a resource manager
      Given a reporter
      Given an email address for player 0
      Then associate player 0's email address with a moniker 
      Given an email address for player 1
      Then associate player 1's email address with a moniker
      Given all players are in the cave
      Then describe the room to each player

   Scenario: produce customized report
      Given a resource manager
      Given a reporter
      Given carps is initialized with server
      Given an editor
      Given an email address for player 0
      Then associate player 0's email address with a moniker
      Given all players are in the cave
      Then customize report for barry 
      Then describe the room to each player

   Scenario: change rooms
      Given a resource manager
      Given a reporter
      Given an email address for player 0
      Then associate player 0's email address with a moniker
      Given all players are in the cave
      Then describe the room to each player
      Given all players are in the ship 
      Then describe the room to each player

   Scenario: different rooms
      Given a resource manager
      Given a reporter
      Given an email address for player 0
      Then associate player 0's email address with a moniker 
      Given an email address for player 1
      Then associate player 1's email address with a moniker
      Given barry is in the cave
      Given paul is in the ship
      Then describe the room to each player

