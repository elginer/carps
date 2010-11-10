require 'rubygems'
gem 'hoe', '>= 2.1.0'
require 'hoe'
require 'fileutils'
$IN_RAKE = true
require './lib/carps'

Hoe.plugin :newgem
Hoe.plugin :website
Hoe.plugin :cucumberfeatures

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec 'carps' do
  self.developer 'John Morrice', 'spoon@killersmurf.com'
  self.post_install_message = File.read 'PostInstall.txt'
  self.rubyforge_name       = self.name
  self.homepage             = "http://github.com/elginer/carps"
  self.description          = File.read "GEM_DESCRIPTION"
  self.summary              = "Computer Assisted Role-Playing Game System" 
  self.extra_deps           = [['highline','>= 1.6.1']]
end

require 'newgem/tasks'
Dir['tasks/**/*.rake'].each { |t| load t }

# TODO - want other tests/tasks run by default? Add them to the list
# remove_task :default
# task :default => [:spec, :features]
