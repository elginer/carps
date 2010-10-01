Feature: sessions
   As a CARPS player,
   whose going to play more than one game,
   across a period of weeks,
   it's desirable for the system to have sessions support,
   because that means that while playing one game,
   I won't receive a message
   intended for a different game.

   Scenario: accept message for this session
      Given a session manager
      Then accept a message meant for this session

   Scenario: deny message intended for another session
      Given a session manager
      Then deny a message intended for another session
