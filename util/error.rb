# Output an error message and quit with exit code 1
def fatal msg
   $stderr.write "\nFATAL ERROR:\n#{msg}\n"
   if $!
      $stderr.write "Error reported:\n#{$!}\n"
   end
   puts "\a"
   exit 1
end
