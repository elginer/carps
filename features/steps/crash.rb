require "carps/util"

Given /^a proc that won't crash$/ do
   $proc = lambda {}
end

Then /^the crash reporter won't report a crash$/ do
   CARPS::with_crash_report do
      $proc.call
   end
end

Given /^a proc that will crash$/ do
   $proc = lambda do
      raise StandardError, "This is a delibrate crash caused for testing purposes."
   end
end

Then /^the crash reporter will report a crash$/ do
   begin
      CARPS::with_crash_report do
         $proc.call
      end
   rescue SystemExit => e
      puts "Recovered from system exit."
   end
end
