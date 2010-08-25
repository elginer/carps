# Configuration files that read yaml
class YamlConfig 

   # Takes as an argument a path to a yaml configuration file
   def initialize filepath
      read filepath
   end

   # Subclasses must create a method parse_yaml which takes YAML returns an array
   def parse_yaml conf
      []
   end

   # Subclasses may create a method load_resource
   # This is called after parsing - hence errors which occur here are not attributed to the configuration file
   # which takes each element of parse_yaml's return array as an argument
   # (This method is called with the result of parse_yaml, with the *[] syntax)
   def load_resources forget
   end

   # Read a resource using the subclass' parse_yaml
   # Then load this resource using the subclass' load_resource
   def read filepath
      contents = ""
      result = nil
      # Try to read the  file
      begin
         contents = File.read filepath
      rescue
         # On failure, write a message to stderr and exit
         fatal "Could not find configuration file: " + conf
      end

      # Try to parse the file
      begin
         conf = YAML.load contents
         result = parse_yaml conf
      rescue
         fatal "Error parsing #{filepath}:\n#{$!}"
      end

      if result
         load_resources *result
      end
   end

   # Attempt to find field within the conf hash
   def read_conf conf, field
      val = conf[field]
      unless val 
         raise "Could not find field: #{field}"
      end
      val
   end
end
