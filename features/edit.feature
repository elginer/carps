Feature: editor

   As a CARPS user,
   to edit character sheets and stuff,
   I want to use a text editor.

   Scenario: edit text
      Given carps is initialized with test/client
      Given a text editor
      Then edit some text
