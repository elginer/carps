# All keywords are prefixed by \30carp.  \30 is an illegal character for users to type
def carp_prefix
   "\30carp_"
end

# Declare a new protocol keyword which is associated with a value
def def_info keyword
   define_singleton_method keyword, proc {carp_prefix + keyword}
   define_singleton_method "new_" + keyword, proc {|data| carp_prefix + keyword + data + carp_end}
end

# Declare a new protocol keyword which is not associated with a value: it is a marker or a flag or a record separator
def def_mark keyword
   define_singleton_method keyword, proc {mark_carp_prefix + keyword}
   define_singleton_method "new_" + keyword, proc {|data| mark_carp_prefix + word + data}
end

# Marker keywords are prefixed with carp_prefix + "mark"
def mark_carp_prefix
   carp_prefix + "mark_"
end

# The protocol follows:
def_mark "init"

def_mark "end"

def_mark "invite"

def_info "master"

def_info "mod"

def_info "code"

def_info "about"

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
      value, blob = blob.split carp_end, 2
      check value, carp_end
      return [value, blob] 
   else
      throw StandardError "Invalid keyword"
   end
end
