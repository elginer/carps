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

require "carps/util/error"

require "yaml"

module CARPS

   # Configuration files that read yaml
   class YamlConfig 

      # Load a yaml file.
      # Provided so subclasses can override initialize
      def self.load fatal=true, filepath=self.default_file
         config = self.allocate
         config.read filepath
         config.fail_hard fatal
         config
      end

      # Should we fail hard, quiting the program?
      def fail_hard fatal
         @fatal = fatal
      end

      # Takes as an argument a path to a yaml configuration file
      def initialize filepath, fatal=true
         fail_hard fatal
         read filepath
      end

      # Read a resource using the subclass' parse_yaml.
      #
      # Then load this resource using the subclass' load_resource
      def read filepath
         filepath = $CONFIG + filepath
         contents = ""
         result = nil
         # Try to read the  file
         begin
            contents = File.read filepath
         rescue
            # On failure, write a message to stderr and exit
            err "Could not read configuration file: " + filepath 
         end

         # Try to parse the file
         begin
            conf = YAML.load contents
            result = parse_yaml conf
         rescue
            err "Error parsing #{filepath}:\n#{$!}"
         end

         if result
            load_resources *result
         end
      end

      protected

      # Subclasses must create a method parse_yaml which takes YAML returns an array
      def parse_yaml conf
         []
      end

      # Subclasses may create a method load_resource
      #
      # This is called after parse_yaml - hence errors which occur here are not attributed to parsing the configuration file
      #
      # Takes each element of parse_yaml's return array as an argument, as in
      # it is called with the result of parse_yaml, like so: 
      #
      # load_resources *parse_yaml conf 
      def load_resources forget
      end

      # Attempt to find field within the conf hash
      def read_conf conf, field
         val = conf[field]
         unless val 
            raise "Could not find field: #{field}"
         end
         val
      end

      # Raise error
      def err msg
         if @fatal
            fatal msg
         else
            raise StandardError, msg
         end
      end

   end

end
