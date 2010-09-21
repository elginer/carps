Feature: start a game
   In order to play carps, the dm must start a game

   Scenario: load mod
      Given a mod file mods.yaml
      Then find the location of a dm mod program

   Scenario: start new game
      Given a mod file mods.yaml
      Then find the location of a dm mod program
      Then find a set of resources called rot
      Then set up a new game

   Scenario: resume game
      Given a game file games.yaml
      Then the dm resumes a previous game

   Scenario: start game interface
      Given a mod file
      Then present the start game interface to the dm
