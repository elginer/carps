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

require "carps/service/interface"

require "carps/util/error"

require "fileutils"

# A wizard is composed of a number of Interfaces.
# Each interface corresponds to a single configuration step.
# Each step is run in sequence.
# The wizard is complete after all its steps have completed.
module CARPS

   # A wizard
   class Wizard < Interface

      def initialize
         create_directories
         @steps = [] 
      end

      # Run the wizard
      def run
         puts description
         @steps.each do |step|
            puts "This wizard will configure CARPS, under your instructions."
            puts "There are a number of steps:"
            puts ""
         end
         (1..@steps.length).each do |step_num|
            puts "#{step_num}: #{@steps[step_num].description}"
         end
         @steps.each do |step|
            step.run
         end
      end

      # Would this be the first time the wizard has run?
      def self.first_time?
         fs = @files.all? do |file|
            File.exists? $CONFIG + "/" + file
         end
         ds = @dirs.all? do |dir|
            real_dir = $CONFIG + "/" + dir
            if File.exists? real_dir
               File.ftype(real_dir) == "directory"
            else
               false
            end
         end
         not (fs and ds)
      end

      # Set the files we are going to use
      def self.set_files *files
         @files = files
      end

      # Set the directories to create upon starting the wizard
      def self.set_dirs *dirs
         @dirs = dirs
      end

      protected

      # Set the steps the wizard is to use. 
      def set_steps *steps
         @steps = steps
      end

      # Create directories
      def create_directories
         @dirs.each do |dir|
            real_dir = $CONFIG + "/" + dir
            if File.exists? real_dir
               unless File.ftype(real_dir) == "directory"
                  fatal "#{real_dir} was not a directory.  CARPS needs this space:  move it elsewhere!"
               end
            else
               FileUtils.mkdir real_dir
            end
         end
      end

   end

end

CARPS::Wizard.set_files
CARPS::Wizard.set_dirs
