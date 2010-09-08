Feature:  Interprocess Communication
   In order to launch mods
   CARPS should be able to
   fork subprograms and communicate with them

   Scenario: fork subprogram
      Given carps is initialized with client
      Given an object to be mutated 
      When the $process.ashare method is run with a computation to mutate the object
      Then I should see 'It works' from the server side

   Scenario: fork subprogram in another shell
      Given an object to be mutated
      When the $process.launch method is called with the name of a ruby subprogram, which I should see in another window
      Then I should see 'It works' from the server side 
