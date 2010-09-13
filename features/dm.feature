Feature: High-level DM interface

   Scenario: meaningful interaction
      Given a high level interface
      Given a character sheet from barry
      Then set barry's status conditionally
      Then preview player turns 
