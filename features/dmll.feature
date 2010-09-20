Feature: Low-level DM interface components
   The DM requires a powerful interface
   To communicate with the players

   Scenario: produce reports
      Given a resource manager
      Given a reporter
      Then the reporter is registered with the resource manager
      Given a player called barry
      Given all players are in the cave
      Then take player turns 

   Scenario: produce customized report
      Given a resource manager
      Given a reporter
      Then the reporter is registered with the resource manager
      Given carps is initialized with test/server
      Then a player called barry
      Given all players are in the cave
      Then customize report for barry 
      Then take player turns

   Scenario: change rooms
      Given a resource manager
      Given a reporter
      Then the reporter is registered with the resource manager
      Given a player called barry
      Given all players are in the cave
      Then take player turns 
      Given all players are in the ship 
      Then take player turns

   Scenario: different rooms
      Given a resource manager
      Given a reporter
      Then the reporter is registered with the resource manager
      Given a player called barry
      Given a player called paul
      Given barry is in the cave
      Given paul is in the ship
      Then take player turns

   Scenario: global question
      Given a reporter
      Given a player called barry
      Then ask everyone what do you do?
      Then take player turns

   Scenario: individual question
      Given a reporter
      Given a player called barry
      Given a player called paul
      Then ask barry only: do you like paul?
      Then ask paul only: does barry smell?
      Then take player turns

   Scenario: create NPC
      Given a resource manager
      Given a reporter
      Given a player called barry
      Given an NPC called paul of type human
      Then report the strength of the NPC paul to barry
      Then take player turns
