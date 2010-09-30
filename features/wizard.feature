Feature: wizard
   In order to play CARPS
   we must have a valid configuration

   Scenario: configure player
      Given carps is initialized with wizard
      Given a player wizard
      Then run the wizard

   Scenario: configure dungeon master
      Given carps is initialized with wizard
      Given a master wizard
      Then run the wizard

   Scenario: detect missing files
      Given carps is initialized with wizard
      Given a sweet wizard
      Then detect missing files

   Scenario: confirm files present
      Given carps is initialized with wizard
      Given a salty wizard
      Then confirm files are present

   Scenario: build needed directories
      Given carps is initialized with wizard
      Given a salty wizard
      Given a partially populated folder
      Then build needed directories

   Scenario: fail on error
      Given carps is initialized with wizard
      Given a salty wizard
      Given an invalid file
      Then the wizard causes the program to exit
      

