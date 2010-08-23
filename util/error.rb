# Output an error message and quit with exit code 1
def fatal msg
   $stderr.write "FATAL ERROR:\n#{msg}\n"
   exit 1
end
