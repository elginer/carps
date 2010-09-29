Feature: Low-level DM interface components
   The DM requires a powerful interface
   To communicate with the players

   Scenario: produce reports
      Given a resource manager
      Given a reporter
      Then the reporter is registered with the resource manager
      Given barry are in the cave
      Then take turns for barry 

   Scenario: produce customized report
      Given a resource manager
      Given a reporter
      Then the reporter is registered with the resource manager
      Given carps is initialized with test/server
      Given barry are in the cave
      Then customize report for barry 
      Then take turns for barry 

   Scenario: change rooms
      Given a resource manager
      Given a reporter
      Then the reporter is registered with the resource manager
      Given barry are in the cave
      Then take turns for barry
      Given barry are in the ship 
      Then take turns for barry

   Scenario: different rooms
      Given a resource manager
      Given a reporter
      Then the reporter is registered with the resource manager
      Given barry are in the cave
      Given paul are in the ship
      Then take turns for barry paul

   Scenario: global question
      Given a reporter
      Given barry are in the cave
      Then ask barry: what do you do?
      Then take turns for barry

   Scenario: individual question
      Given a reporter
      Then ask barry: do you like paul?
      Then ask paul: does barry smell?
      Then take turns for barry paul

   Scenario: create NPC
      Given a resource manager
      Then create an NPC of type human
