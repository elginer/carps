Feature: player initialization

   Scenario: player start game interface
      Given carps is initialized with test/client
      Given a session manager
      Given a mailer stub for the player start interface
      When an invite is sent to the player
      Then present the start game interface to the player
