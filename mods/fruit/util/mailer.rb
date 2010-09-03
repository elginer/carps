require "text/rainbow"

require "drb"

# Get a reference to the mailer object
def init_mailer
   mailer_url = ARGV.shift
   puts rainbow "Listening on " + mailer_url
   DRbObject.new nil, mailer_url
end
