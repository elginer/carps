Feature: High-level DM interface

   Scenario: produce report 
      Given a DM mod
      Given a character sheet from barry
      Then set barry's status conditionally
      Then preview player turns 
