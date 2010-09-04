require "mod/status_report"
require "mod/question"
require "mod/answers"

Given /^a status report$/ do
   $status = StatusReport.new "dungeon master", "This is some might important information here!"
end

Then /^the status report should be printed$/ do
   $status.display
end

Given /^a question$/ do
   $question = Question.new "dungeon master", "What do you do?"
end

Then /^the question should be asked$/ do
   ans = Answers.new "dungeon master"
   $question.ask ans
end
