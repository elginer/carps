Feature: dice
   In order to play an RPG
   You have to whittle some dice

   Scenario: random integer
      Given 1000 random integers between 12 and 15
      Then ensure each of the random numbers are between 12 and 15

   Scenario: random float
      Given 1000 random floats between 35 and 40
      Then ensure each of the random numbers are between 35 and 40

   Scenario: probabalistic interface
      Given an interface to dice rolling
      Then launch the probabalistic interface
