Feature: email
   In order for CARPS peers to communicate over the network in a distributed fashion
   CARPS should be able to
   Send and receive emails

   Scenario: send email
      Given carps is initialized with test/client
      Given default IMAP settings
      Given default SMTP settings
      Given the email account
      Then an email is sent

   Scenario: receive email
      Given carps is initialized with test/client
      Given default IMAP settings
      Given default SMTP settings
      Given the email account
      Then an email is received

   Scenario: SMTP security
      Given carps is initialized with test/client
      Given default SMTP settings
      Then attempt connections with various SMTP security settings


   Scenario: IMAP security
      Given carps is initialized with test/client
      Given default IMAP settings 
      Then attempt connections with various IMAP security settings
