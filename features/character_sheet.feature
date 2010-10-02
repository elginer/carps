Feature: character sheets
   As a CARPS player,
   In order to play an RPG,
   You need a character,
   So you need a character sheet.

   Scenario: fill in character sheet
      Given carps is initialized with test/client
      Given a character sheet schema
      Given a sheet editor
      Then fill in the character sheet

   Scenario: parsable character sheet
      When an parsable sheet is provided
      Then parse the sheet

   Scenario: unparsable character sheet
      When an unparsable sheet is provided
      Then do not parse the sheet

   Scenario: fill in the sheet again
      Given carps is initialized with test/client
      Given a character sheet schema
      Given a sheet editor
      Then fill in the character sheet 
      Then edit the character sheet again

   Scenario: accept valid character sheet
      Given carps is initialized with test/client
      Given a character sheet schema
      Given a sheet editor
      When a valid sheet is provided
      Then accept the valid sheet

   Scenario: do not accept invalid character sheet
      Given carps is initialized with test/client
      Given a character sheet schema
      Given a sheet editor
      When an invalid sheet is provided
      Then do not accept the invalid sheet
