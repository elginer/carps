Feature: user interface
   In order for people to use carps
   Well
   They have to be able to use it

   Scenario: user interface
      Given a cheesey interface
      Then present the cheesey interface to the user

   # This is important because it lets me know when a interface is broken
   # Also, it corrects the problem
   # Further, it's best to tell the user rather than silently drop it
   # in case they think it is supposed to have the option and are surprised 
   # when it doesn't
   Scenario: broken interface
      Given a broken interface created by a drunk
      Then present the interface, reporting the mistake to the user
