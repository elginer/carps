Feature: character sheets
   In order to play an RPG
   You need a character

   Scenario: fill in character sheet
      Given carps is initialized with test/client
      Given a character sheet schema
      Then fill in the character sheet

   Scenario: fill in the sheet again
      Given carps is initialized with test/client
      Given a character sheet schema
      Then fill in the character sheet 
      Then edit the character sheet again
