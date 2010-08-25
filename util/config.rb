# Configuration files that read yaml
class YamlConfig 
   # A little helper method
   def read_conf conf, field
      val = conf[field]
      if val == nil
         raise "Could not find field: #{field}"
      end
      val
   end
end
