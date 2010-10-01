Feature: message parsing
   In order to send complicated messages through the ether
   They must be parsed

   Scenario: parse invitation
      Given an invitation
      Given a client parser
      Then emit the invitation
      Then parse the invitation
