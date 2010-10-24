require "carps/util/init"

Given /^carps is initialized with (.+)$/ do |config|
   CARPS::init 0, config
end
