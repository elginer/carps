# Designed to help test/features/step/ipc.rb
# To be launched in another shell window

require "drb"

begin
   mut = DRbObject.new nil, ARGV.shift
   mut.mutate!
   puts mut.works?
   puts "Press any key to exit"
   gets
rescue Exception => e
   puts e
   gets
end
