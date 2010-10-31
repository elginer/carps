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

require "carps/ui/warn"

require "yaml"

module CARPS

   # Configuration files that read yaml
   class YamlConfig 

      # Should we fail hard, quiting the program?
      def fail_hard fatal
         @fatal = fatal
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

      # Save as a YAML file
      def save_file path
         y = emit.to_yaml 
         begin
            file = File.new $CONFIG + path, "w"
            file.write y
            file.close
         rescue StandardError => e
            UI::warn "Could not save #{self.class} as #{path}: #{e}"
         end
      end

      # Emit as yaml
      def emit
      end

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
      def load_resources *forget
      end

      # Attempt to find field within the conf hash
      def read_conf conf, field
         unless conf.include? field
            raise "Could not find field: #{field}"
         end
         conf[field] 
      end

      # Raise error
      def err msg
         if @fatal
            CARPS::fatal msg
         else
            raise StandardError, msg
         end
      end

   end

   # User configurations, which may be stored in many files
   # and which should not crash the system on an error
   class UserConfig < YamlConfig

      # Subclasses must call super
      def initialize
         fail_hard false
      end

      # Load a user file.
      def self.load filepath
         config = self.allocate
         config.read filepath
         config.fail_hard false 
         config
      end

   end

   # System configurations, which exist in strictly predefined locations
   # and which should crash the system if they do not exist, because they
   # are critical to its operation.
   class SystemConfig < YamlConfig

      # Subclasses must call super
      def initialize
         fail_hard true
      end

      # Load a system file.
      def self.load
         config = self.allocate
         config.read self.filepath
         config.fail_hard false 
         config
      end

      # Save the user config
      def save
         save_file self.class.filepath
      end
      

   end

end
