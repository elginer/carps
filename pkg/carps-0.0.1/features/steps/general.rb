require "carps/util/init"

include CARPS

Given /^carps is initialized with (.+)$/ do |config|
   init config
end
