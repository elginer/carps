class Room

   def initialize filepath
      @desc = File.read filepath
   end

   def describe
      @desc
   end

end
