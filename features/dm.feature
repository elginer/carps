Feature: High-level DM interface

   Scenario: produce report 
      Given a DM mod
      Given carps is initialized with test/server
      Given a character sheet schema
      When barry joins the mod
      Then check barry's sheet
      Then set barry's status conditionally
      Then preview player turns

   Scenario: create npc
      Given a DM mod
      Given carps is initialized with test/server
      Given a character sheet schema
      Then create an NPC called paul of type orange 
      When barry joins the mod
      Then check barry's sheet
      Then report the strength of the NPC paul to barry
      Then preview player turns

   Scenario: user interaction
      Given a DM mod
      Given a character sheet schema
      Given carps is initialized with test/server
      When someone requests to join the mod
      Then present a user interface to the DM
