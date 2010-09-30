Feature: wizard
   In order to play CARPS
   we must have a valid configuration

   Scenario: detect missing files
      Given the config directory is wizard
      Then clean the wizard directory
      Given a sweet wizard
      Then detect missing files

   Scenario: confirm files present
      Given the config directory is wizard
      Then clean the wizard directory
      Given a salty wizard
      Then confirm files are present

   Scenario: build needed directories
      Given the config directory is wizard
      Then clean the wizard directory
      Given a salty wizard
      Given a partially populated folder
      Then the salty wizard builds needed directories

   Scenario: fail on error
      Given the config directory is wizard
      Then clean the wizard directory
      Given a salty wizard
      Given one of the salty wizard's files is in fact a directory
      Then the wizard, attempting to create files, causes the program to exit

   Scenario: configure player
      Given the config directory is wizard
      Then clean the wizard directory
      Given a player wizard
      Then run the wizard

   Scenario: configure dungeon master
      Given the config directory is wizard
      Then clean the wizard directory
      Given a master wizard
      Then run the wizard
