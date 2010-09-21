Feature: start a game
   In order to play carps, the dm must start a game

   Scenario: start new game
      Given carps is initialized with test/server
      Then host a new game called rot with resource campaign and mod fruit
      Then save the game as rot.yaml

   Scenario: resume game
      Given carps is initialized with test/server
      Then the dm resumes a previous game called rot.yaml

   Scenario: start game interface
      Given carps is initialized with test/server
      Then present the start game interface to the dm
