Feature: crash

   As a CARPS user,
   If CARPS were to unfortunately crash,
   Perhaps because its developer is a tool,
   I expect a nice crash report that doesn't
   mess up my screen.

   Scenario: no crash
      Given a proc that won't crash
      Then the crash reporter won't report a crash

   Scenario: crash
      Given a proc that will crash
      Then the crash reporter will report a crash
