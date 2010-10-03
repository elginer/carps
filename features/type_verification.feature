Feature: type verification
   In order to verify character sheets correctly
   the basic types making up those character sheets must be verified

   Scenario: accept integer as integer
      Given an integer
      Then verify: accept as a integer

   Scenario: accept integer as optional integer
      Given an integer
      Then verify: accept as a optional integer

   Scenario: accept nil as optional integer
      Given a nil value
      Then verify: accept as a optional integer

   Scenario: deny nil as integer
      Given a nil value
      Then verify: deny as a integer

   Scenario: deny string as integer
      Given a string
      Then verify: deny as a integer

   Scenario: deny string as optional integer
      Given a string
      Then verify: deny as a optional integer

   Scenario: accept boolean as boolean
      Given 'yes'
      Then verify: accept as a boolean

   Scenario: accept nil as optional choice gold silver
      Given a nil value
      Then verify: accept as a optional choice gold silver

   Scenario: accept nil as optional boolean
      Given a nil value
      Then verify: accept as a optional boolean

   Scenario: accept gold as choice gold silver
      Given 'gold'
      Then verify: accept as a choice gold silver

   Scenario: deny bronze as choice gold silver
      Given 'bronze'
      Then verify: deny as a choice gold silver

