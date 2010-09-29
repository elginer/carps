Feature: Player interface
   In order to play carps
   the player needs to be able
   to interact with a mod

   Scenario: player user interaction
      Given a character sheet schema
      Given carps is initialized with test/client
      Given a player test mailer
      Given a player mod
      When the player receives turn information
      Then present a user interface to the player
