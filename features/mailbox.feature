Feature: mailbox
   As a CARPS user,
   I need a way to reliably send and receive emails.

   Scenario: mail persistence
      Given carps is initialized with test/client
      Then .mail is cleaned
      Given a session manager
      Given a testing mailbox
      Then send mail with session 1 to the mailbox
      When the user presses enter, continue
      Given a testing mailbox
      Then receive mail with session 1

   Scenario: no session
      Given carps is initialized with test/client
      Then .mail is cleaned
      Given a session manager
      Given a testing mailbox
      Then send mail with session 1 to the mailbox
      Then receive mail with session 1

   Scenario: session
      Given carps is initialized with test/client
      Then .mail is cleaned
      Given a session manager
      Given a testing mailbox
      Then send mail with session 1 to the mailbox
      Then send mail with session 2 to the mailbox
      Then set session to 2
      Then receive mail with session 2 
      Then check that the mail with session 1 has not been received

