Feature: client turns
   In order for people to play a game
   The players must be able to
   Answer questions set by the Dungeon Master

   Scenario: answer question
      Given a question
      Then the question should be asked

   Scenario: read report
      Given a status report
      Then the status report should be printed

   Scenario: take turn
      Given a status report and a number of questions
      Then all the questions should be asked 
