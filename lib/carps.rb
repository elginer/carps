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

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require "carps/util"
require "carps/protocol"
require "carps/email"
require "carps/crypt"
require "carps/service"
require "carps/mod"
require "carps/wizard"


# CARPS, the Computer Assisted Role-Playing Game System,
# is a tool for playing pen and paper RPGs over the internet.
# 
# CARPS is:
#
# extensible; game rules are provided by extensions to CARPS.
# 
# decentralized; CARPS' protocol is a layer on top of email. 
#
# secure; CARPS messages are cryptographically signed to prevent spoofing
#
#
# The CARPS module which functions as a namespace for CARPS classes.
module CARPS
  VERSION = '0.1.0'
end
