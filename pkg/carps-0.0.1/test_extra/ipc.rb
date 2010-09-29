# Designed to help test/features/step/ipc.rb
# To be launched in another shell window

require "drb"

begin
   url = ARGV.shift
   puts "Listening on " + url
   mut = DRbObject.new nil, url
   mut.mutate!
   puts mut.works?
rescue Exception => e
   puts "ERROR:"
   puts e
end
puts "Press enter to exit"
gets
