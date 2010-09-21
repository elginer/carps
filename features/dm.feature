Feature: High-level DM interface

   Scenario: produce report 
      Given a DM mod
      Given carps is initialized with test/server 
      When barry joins the mod
      Then check barry's sheet
      Then set barry's status conditionally
      Then preview player turns

   Scenario: create npc
      Given a DM mod
      Then create an NPC of type human called paul
      Then report the strength of the NPC paul to barry
      Then preview player turns

   Scenario: user interaction
      Given a DM mod
      Given carps is initialized with test/server
      Then present a user interface to the DM
