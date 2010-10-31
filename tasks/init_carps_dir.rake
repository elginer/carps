# Create the user directory for carps

require "carps/util/init"

require "fileutils"

task :setup_carps_dir do
   root = CARPS::root_config
   mkdir root
   mkdir root + "player/"
   mkdir root + "dm/"
   touch root + "mods.yaml"
end
