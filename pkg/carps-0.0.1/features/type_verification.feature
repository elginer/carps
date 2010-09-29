Feature: type verification
   In order to verify character sheets correctly
   the basic types making up those character sheets must be verified

   Scenario: accept integer as integer
      Given an integer
      Then verify: accept as an integer

   Scenario: accept integer as optional integer
      Given an integer
      Then verify: accept as an optional integer

   Scenario: accept nil as optional integer
      Given a nil value
      Then verify: accept as an optional integer

   Scenario: deny nil as integer
      Given a nil value
      Then verify: deny as an integer

   Scenario: deny string as integer
      Given a string
      Then verify: deny as an integer

   Scenario: deny string as optional integer
      Given a string
      Then verify: deny as an optional integer
