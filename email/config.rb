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


require "email/imap"
require "email/smtp"

require "util/error"
require "util/config"

require "crypt/mailer"

require "yaml"

# Class to read email config.
class EmailConfig < YamlConfig

   # The first parameter is the config file to read
   # the second is the MessageParser for parsing messages from email
   def initialize conf, message_parser 
      @message_parser = message_parser
      super conf
   end


   # Parse the email config file
   def parse_yaml conf
      username = read_conf conf, "username"
      password = read_conf conf, "password"
      imap_server = read_conf conf, "imap"
      smtp_server = read_conf conf, "smtp"
      [imap_server, smtp_server, username, password]        
   end

   # Connect to the imap and smtp servers
   def load_resources imap_server, smtp_server, username, password 
      imap = IMAP.new imap_server, username, password
      smtp = SMTP.new smtp_server, username, password
      @mailer = Mailer.new username, imap, smtp, @message_parser
   end

   # Return the high level mail client
   def mailer
      @mailer
   end
end
