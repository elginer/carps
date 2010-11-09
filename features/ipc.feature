Feature:  Interprocess Communication
   In order to launch mods
   CARPS should be able to
   fork subprograms and communicate with them

   Scenario: fork subprogram in another shell
      Given carps is initialized with test/client
      Given an object to be mutated
      When the Process.launch method is called with the name of a ruby subprogram, which I should see in another window
      Then I should see 'It works' from the server side 
