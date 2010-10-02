Feature: timeout
   As a programmer,
   I find ruby's timeout lacking.

   Scenario: timeout
      Given a long running command
      Then timeout the command after 1 second 

   Scenario: no timeout
      Given a short command
      Then give the command 1 second to complete
