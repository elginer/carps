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

# CARP protocol keywords associated with values are prefixed by ASCII start of text.
def prefix
   "\2"
end

# CARP protocol markers are associated with ASCII start of heading
def mark_prefix
   "\1"
end

# End the prefix, so there are no ambiguities
def keyword_end
   "\3"
end

# Class containing message keywords.  Its name is short :)
class K
end

# Class containing message keywords which are associated with values.
class V
end

# Declare a new protocol keyword which is associated with a value
def protoval keyword
   # Use the OLD SKOOL for ruby 1.8 (and cucumber!) support
   K.class_eval <<-"END"
      def K.#{keyword.to_s}
         prefix + "#{keyword.to_s}" + keyword_end
      end
   END
   V.class_eval <<-"END"
      def V.#{keyword.to_s} data
         prefix + "#{keyword.to_s}" + keyword_end + data + K.end
      end
   END
end

# Declare a new protocol keyword which is a flag or marker 
def protoword keyword
   # Use the OLD SKOOL for ruby 1.8 (and cucumber!) support
   K.class_eval <<-"END"
      def K.#{keyword.to_s}
         mark_prefix + "#{keyword.to_s}"
      end
   END
end

# End keyword 
protoword "end"

class Expected < StandardError
end

# Check that the first argument is not nil, if so, raise an 'expected' parse error, using the second argument
def check result, expected
   if result == nil
      raise Expected, expected
   end
end

# Find a field in semi-structured text
def find field, text
   if field.start_with? mark_prefix
      forget, blob = text.split field, 2
      check blob, field
      return ["", blob]
   elsif field.start_with? prefix
      forget, blob = text.split field, 2
      check blob, field
      value, blob = blob.split K.end, 2
      check value, K.end
      return [value, blob] 
   else
      raise StandardError, "Invalid keyword"
   end
end
