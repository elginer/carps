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


require "carps/email/imap"
require "carps/email/smtp"

require "carps/util/error"
require "carps/util/config"
require "carps/util/question"

require "carps/crypt/mailer"
require "carps/crypt/mailbox"

require "yaml"

require "highline"

module CARPS

   # Class to read email config.
   class EmailConfig < YamlConfig

      # The first parameter is the config file to read
      # the second is the MessageParser for parsing messages from email
      def initialize conf
         super conf
      end


      # Parse the email config file
      def parse_yaml conf
         username = read_conf conf, "username"
         address = read_conf conf, "address"
         h = HighLine.new
         password = secret "Enter password for #{username}:" 
         imap = read_conf conf, "imap"
         unless imap["server"] and imap["port"] and imap["tls"]
            raise Expected, "Valid IMAP section"
         end
         smtp = read_conf conf, "smtp"
         unless smtp["server"] and smtp["port"] and smtp["starttls"]
            raise Expected, "Valid SMTP section"
         end
         [imap, smtp, username, address, password]        
      end

      # Connect to the imap and smtp servers
      def load_resources imap_settings, smtp_settings, username, address, password
         @address = address
         @imap = IMAP.new imap_settings, username, password
         @smtp = SMTP.new smtp_settings, username, password
      end

      # Return the high level mail client
      def mailer message_parser
         mailbox = Mailbox.new @smtp, @imap, message_parser
         Mailer.new @address, mailbox
      end

   end

end
