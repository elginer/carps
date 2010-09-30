require "carps/wizard/wizard"
require "carps/wizard/player"
require "carps/wizard/master"

require "fileutils"

include CARPS

$sweet_files = ["roses", "kittens"]
$salty_files = ["robots", "miniguns"]
$salty_dirs = ["strength", "power"]

class SweetWizard < Wizard
end

SweetWizard.set_files *$sweet_files
SweetWizard.set_dirs

class SaltyWizard < Wizard
end

SaltyWizard.set_files *$salty_files
SaltyWizard.set_dirs *$salty_dirs

Given /^a player wizard$/ do
   $wizard = PlayerWizard.new
end

Given /^a master wizard$/ do
   $wizard = MasterWizard.new
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
      raise "The wizard thought the files were present when they were not."
   end
end

Given /^a salty wizard$/ do
   FileUtils.touch $CONFIG + $salty_files
   $wizard = SaltyWizard.new
end

Then /^confirm files are present$/ do
   if $wizard.first_time?
      raise "The wizard thought the files were not present when they were."
   end
end

Given /^a partially populated folder$/ do
   FileUtils.rmdir $CONFIG + $salty_dirs[0]
end
