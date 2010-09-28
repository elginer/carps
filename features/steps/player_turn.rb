require "mod/status_report"
require "mod/answers"
require "mod/client_turn"

require "mod/question"

Given /^a status report$/ do
   $status = StatusReport.new "This is some might important information here!"
end

Then /^the status report should be printed$/ do
   $status.display
end

Given /^a question$/ do
   $question = Question.new "What do you do?"
end

Then /^the question should be asked$/ do
   ans = Answers.new
   $question.ask ans
   puts "Our conversation:"
   ans.display
end

Given /^a status report and a number of questions$/ do
   s = StatusReport.new "Halt, mortal!"
   q1 = Question.new "Who are you?"
   q2 = Question.new "What are you doing here?"
   $turn = ClientTurn.new CharacterSheet.new({}), s, [q1, q2]
end

Then /^all the questions should be asked$/ do
   class Tester
      def send to, answers
         puts "To be sent to #{to}"
         answers.display
      end
   end
   tester = Tester.new
   tester.send "dungeon master", $turn.take
end
