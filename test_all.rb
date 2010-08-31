#! /usr/bin/ruby1.9.1

test_dir = Dir.open "test"

tests = test_dir.entries.reject do |t|
   File.ftype("test/" + t) != "file" or t[0] == "."
end

tests = tests.map do |t|
   "test/" + t
end

tests.each do |t|
   load t
   unless test
      puts "TEST FAILED: " + t
      break
   end
end
