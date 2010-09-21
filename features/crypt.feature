Feature: cryptography
   In order for CARPS peers to communicate without the risk of someone pretending to be a peer when he isn't
   CARPS must
   sign each message using strong public key cryptography

   Scenario: handshake
      Given two peers, Alice and Bob
      Then Alice initiates a handshake request and Bob accepts
      Then Alice and Bob's mailers are shut down

   Scenario: hacker
      Given two peers, Alice and Bob
      Then Alice initiates a handshake request and Bob accepts
      Then a hacker pretending to be Alice sends a nefarious message to Bob
      Then Alice and Bob's mailers are shut down

   Scenario: spoofer
      Given two peers, Alice and Bob
      Then Alice initiates a handshake request and Bob accepts
      Then a spoofer pretending to be Bob tries to make a handshake with Alice
      Then Alice and Bob's mailers are shut down
