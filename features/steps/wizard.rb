require "carps/wizard/wizard"
require "carps/wizard/player"
require "carps/wizard/master"

require "fileutils"

include CARPS

$sweet_files = ["roses", "kittens"]
$salty_files = ["robots", "miniguns"]
$salty_dirs = ["strength", "power"]

class SweetWizard < Wizard

   def initialize
      super $sweet_files, []
   end

end

class SaltyWizard < Wizard

   def initialize
      super $salty_files, $salty_dirs
   end

end

Given /^a player wizard$/ do
   $wizard = Player::Wizard.new
end

Given /^a master wizard$/ do
   $wizard = DM::Wizard.new
end

Then /^clean the wizard directory$/ do
   wiz = root_config + "/wizard/"
   FileUtils.rm_rf wiz
   FileUtils.mkdir wiz
end

Then /^run the wizard$/ do
   $wizard.run
end

Given /^a sweet wizard$/ do
   FileUtils.touch $CONFIG + $sweet_files[0]
   $wizard = SweetWizard.new
end

Then /^detect missing files$/ do
   unless $wizard.first_time?
      raise StandardError, "The wizard thought the files were present when they were not."
   end
end

Given /^a salty wizard$/ do
   FileUtils.touch $salty_files.map {|f| $CONFIG + "/" + f}
   FileUtils.mkdir $salty_dirs.map {|f| $CONFIG + "/" + f}
   $wizard = SaltyWizard.new
end

Then /^confirm files are present$/ do
   if $wizard.first_time?
      raise StandardError, "The wizard thought the files were not present when they were."
   end
end

Given /^a partially populated folder$/ do
   FileUtils.rmdir $CONFIG + $salty_dirs[0]
end

Given /^the config directory is (.+)$/ do |dir|
   config_dir dir
end

Then /^the salty wizard builds needed directories$/ do
   $wizard.create_directories
   dirs_exist = $salty_dirs.map {|f| File.exists?($CONFIG + "/" + f)}
   unless dirs_exist.all?
      raise StandardError, "Salty Wizard did not create needed directories."
   end
end

When /^one of the salty wizard's files is in fact a directory$/ do
   file = $CONFIG + "/" + $salty_files[0]
   FileUtils.rm file
   FileUtils.mkdir file
end

Then /^the wizard, attempting to create files, causes the program to exit$/ do
   begin
      $wizard.create_files
   rescue SystemExit => e
      puts e
   end
end
