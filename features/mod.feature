Feature: mods
   In order to play or host a game
   A mod needs to be executed

   Scenario: resume dm mod
      Given carps is initialized with test/server
      Given a session manager
      Given a dm game config
      Then resume the mod

   Scenario: resume player mod
      Given carps is initialized with test/client
      Given a session manager
      Given a player game config
      Then resume the mod
