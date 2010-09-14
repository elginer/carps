Feature: High-level DM interface

   Scenario: produce report 
      Given a DM mod
      Given carps is initialized with server
      When barry joins the mod
      Then check barry's sheet
      Then set barry's status conditionally
      Then preview player turns 
