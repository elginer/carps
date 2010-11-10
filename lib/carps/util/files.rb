# Copyright 2010 John Morrice

# This file is part of CARPS.

# CARPS is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# CARPS is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with CARPS.  If not, see <http://www.gnu.org/licenses/>.

module CARPS

   # Get the file names from inside a directory
   def files dir
      file_names = Dir.open(dir).entries.reject do |file|
         file.untaint
         file[0] == "." or File.ftype(dir + "/" + file) != "file" 
      end
      file_names.map do |fn|
         dir + "/" + fn
      end
   end

   # Write contents into a new file in a directory with an arbitrary, unique name
   #
   # Returns the path
   def write_file_in dir, contents
      t = Time.now
      valid_path = false
      path = $CONFIG + dir + "/" + t.to_f.to_s.gsub(/(\.|@, \?!#'"~\(\))/, "")
      until valid_path
         path += "_"
         valid_path = not(File.exists?(path))
      end
      file = File.new path, "w"
      file.write contents
      file.close
      path
   end

end
