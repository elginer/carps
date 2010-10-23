Feature: rules
   As a CARPS mod writer,
   attempting to encode a game into a CARPS mod,
   in order to manipulate character sheets in accordance
   with the game manuals,
   I require a high level interface for writing rules.

   Scenario: show odds for rule on a character sheet
      Given a character sheet schema
      When a valid sheet is provided
      Given a rule which operates on a character sheet
      Then show the odds for the rule

   Scenario: apply rule on a character sheet
      Given a character sheet schema
      When a valid sheet is provided
      Given a rule which operates on a character sheet
      Then apply the rule

