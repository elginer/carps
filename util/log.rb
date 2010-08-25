# Log a message to stderr
def log reason, msgs
   $stderr.write "\n-------------------\n"
   $stderr.write "Sorry for distracting you from the game but...\n" 
   $stderr.write reason + "\n"
   $stderr.write {msg} + "\n"
   $stderr.write "End of report.\n"
   $stderr.write "\n-------------------\n"
   puts "\a" 
end
