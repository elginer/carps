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

# Class containing message keywords.  Its name is short :)
class K
end

# Class containing message keywords which are associated with values.
class V
end

# Declare a new protocol keyword which is associated with a value
def protoval keyword
   K.define_singleton_method keyword, proc {prefix + keyword}
   V.define_singleton_method keyword, do |data|
      prefix + keyword + data + K.end
   end
end

# Declare a new protocol keyword which is a flag or marker 
def protoword keyword
   K.define_singleton_method keyword, proc {mark_prefix + keyword}
end

# End keyword 
protoword "end"

class Expected < StandardError
end

# Check that the first argument is not nil, if so, throw an 'expected' parse error, using the second argument
def check result, expected
   if result == nil
      throw Expected.new expected
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
      throw StandardError "Invalid keyword"
   end
end
