Feature: mods
   In order to play or host a game
   A mod needs to be executed

   Scenario: resume dm mod
      Given carps is initialized with test/server
      Given a session manager
      Given a dm game config, for mod test
      Then resume the mod

   Scenario: save and load dm mod
      Given carps is initialized with test/server
      Given a session manager
      Given a dm game config, for mod saver
      Then resume the mod
      Then load the DM mod

   Scenario: resume player mod
      Given carps is initialized with test/client
      Given a session manager
      Given a player game config, for mod test
      Then resume the mod
