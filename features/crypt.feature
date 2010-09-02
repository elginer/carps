Feature: cryptography
   In order for CARPS peers to communicate without the risk of someone pretending to be a peer when he isn't
   CARPS must
   sign each message using strong public key cryptography

   Scenario: handshake
      Given two peers, Alice and Bob
      Then Alice initiates a handshake request and Bob accepts
