# Log a message to stderr
def log reason, msg
   $stderr.write "An error was logged:\n"
   $stderr.write reason + "\n"
   $stderr.write msg + "\n"
   $stderr.write "Error raised:\n"
   if $!
      $stderr.write $!.to_s + "\n"
   end
   $stderr.write "End of report.\n"
   puts "\a" 
end
