Feature: message parsing
   In order to send complicated messages through the ether
   They must be parsed

   Scenario: parse invitation
      When an invitation is sent
      Given a client parser
      Then emit the message
      Then parse the message
