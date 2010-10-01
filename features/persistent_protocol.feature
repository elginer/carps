Feature: persistent protocol
   In order to continue playing carps,
   between runs of the program,
   without odd glitches occuring,
   there must be persistency at the protocol level.

   Scenario: persistent message
      Given carps is initialized with test/client
      Given a persistent message
      Then save the message, noting the file name
      Then make sure the file exists 
      Then delete the message
      Then make sure the file was deleted
      
