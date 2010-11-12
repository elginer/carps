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

require "carps/util"

require "carps/ui"

require "fileutils"

# A wizard is composed of a number of Interfaces.
# Each interface corresponds to a single configuration step.
# Each step is run in sequence.
# The wizard is complete after all its steps have completed.
module CARPS

   # A wizard
   class Wizard

      def initialize files, dirs
         @files = files
         @dirs = dirs
         @steps = [] 
      end

      # Run the wizard
      def run
         UI::highlight "Welcome to the CARPS Configuration Wizard"
         puts ""
         puts "This program will configure CARPS, under your instructions."
         puts "There are a number of steps:"
         puts ""
         @steps.each_index do |step_num|
            puts "#{step_num + 1}: #{@steps[step_num].description}"
         end
         puts ""
         @steps.each do |step|
            step.run
            puts ""
         end
         UI::highlight "Tada!  Wizard complete."
         CARPS::enter_quit
      end

      # Would this be the first time the wizard has run?
      def first_time?
         fs = @files.all? do |file|
            real_file = $CONFIG + "/" + file
            if File.exists? real_file
               File.ftype(real_file) == "file"
            else
               false
            end
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

      # Create files
      def create_files
         create_all @files, "file" do |path|
            FileUtils.touch path
         end
      end

      # Create directories
      def create_directories
         create_all @dirs, "directory", do |path|
            FileUtils.mkdir path
         end
      end

      protected

      # Set the files we are going to use
      def set_files *files
         @files = files
      end

      # Set the directories to create upon starting the wizard
      def set_dirs *dirs
         @dirs = dirs
      end

      # Set the steps the wizard is to use. 
      def set_steps *steps
         @steps = steps
      end

      def create_all files, type
         files.each do |dir|
            real_dir = $CONFIG + "/" + dir
            if File.exists? real_dir
               unless File.ftype(real_dir) == type
                  CARPS::fatal "#{real_dir} was not a #{type}.  CARPS needs this space:  move it elsewhere!"
               end
            else
               yield real_dir
            end
         end
      end

   end

end
