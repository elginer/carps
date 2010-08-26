require "email/string"

# All carp keywords associated with values are prefixed by ASCII record separator.
def value_prefix
   "\x1E"
end

# Carp marks are prefixed with ASCII group separator 
def mark_prefix
   "\x1D"
end

# Class containing message keywords.  Its name is short :)
class K
end

# Class containing message keywords which are associated with values.
class V
end

# Declare a new protocol keyword which is associated with a value
def protoval keyword
   K.define_singleton_method keyword, proc {val_prefix + keyword}
   V.define_singleton_method keyword, do |data|
      data = data.match(/^\s*((\S+\s+)*?\S+)\s*$/)[1]
      val_prefix + keyword + data + K.end
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
   if field.start_with? mark_carp_prefix
      forget, blob = text.split field, 2
      check blob, field
      return ["", blob]
   elsif field.start_with? carp_prefix
      forget, blob = text.split field, 2
      check blob, field
      value, blob = blob.split K.end, 2
      check value, K.end
      return [value, blob] 
   else
      throw StandardError "Invalid keyword"
   end
end
