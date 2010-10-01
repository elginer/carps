Feature: cryptography
   In order for CARPS peers to communicate without the risk of someone pretending to be a peer when he isn't
   CARPS must
   sign each message using strong public key cryptography

   Scenario: handshake
      When threading starts
      Given two peers, Alice and Bob
      Then Alice initiates a handshake request and Bob accepts
      When the user presses enter, threading stops

   Scenario: hacker
      When threading starts
      Given two peers, Alice and Bob
      Then Alice initiates a handshake request and Bob accepts
      Then a hacker pretending to be Alice sends a nefarious message to Bob
      When the user presses enter, threading stops

   Scenario: spoofer
      When threading starts
      Given two peers, Alice and Bob
      Then Alice initiates a handshake request and Bob accepts
      Then a spoofer pretending to be Bob tries to make a handshake with Alice
      When the user presses enter, threading stops
