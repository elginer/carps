Feature: character sheets
   In order to play an RPG
   You need a character

   Scenario: fill in character sheet
      Given carps is initialized with test/client
      Given a character sheet schema
      Then fill in the character sheet

