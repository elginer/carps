require "util/process"

require "drb"

class Mutate

   include DRbUndumped

   def initialize
      @works = "Does it fuck work!"
   end

   def mutate
      @works = "It works!"
   end

   def works
      @works
   end

end

def test
   mut = Mutate.new
   process = CARPProcess.new "process.yaml"
   process.ashare mut, lambda {|uri|
      ob = DRbObject.new_with_uri uri
      ob.mutate
      puts "In child:"
      puts ob.works
   }
   puts "In parent:"
   puts mut.works
   mut.works
end
