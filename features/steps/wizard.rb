require "carps/wizard/wizard"

require "fileutils"

$sweet_files = ["roses", "kittens"]
$salty_files = ["robots", "miniguns"]
$salty_dirs = ["strength", "power"]

class SweetWizard < Wizard

   def initialize
      super $sweet_files, []
   end

end

class SillyStep < Setup::Interface

   def initialize
      super
   end

   def description
      "A pretty silly configuration step that doesn't do much."
   end

   def test
      puts "Yup, looks good to me."
      test_passed
   end

end

class SaltyWizard < Wizard

   def initialize
      super $salty_files, $salty_dirs
      set_steps SillyStep.new
   end

end

Then /^setup email$/ do
   em = Setup::Email.new
   em.run
end

Then /^setup processing$/ do
   pr = Setup::Process.new
   pr.run
end

Then /^setup editor$/ do
   ed = Setup::Editor.new
   ed.run
end

Given /^a player wizard$/ do
   $wizard = Player::Wizard.new
end

Then /^clean the wizard directory$/ do
   wiz = CARPS::root_config + "/wizard/"
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
   CARPS::config_dir dir
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
