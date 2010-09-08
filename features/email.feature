Feature: email
   In order for CARPS peers to communicate over the network in a distributed fashion
   CARPS should be able to
   Send and receive emails

   Scenario: send email
      Given carps is initialized with client
      Given the email account
      Then an email is sent

   Scenario: receive email
      Given carps is initialized with client
      Given the email account
      Then an email is received
