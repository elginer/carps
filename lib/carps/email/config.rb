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

require "carps/util/config"

require "carps/ui/question"

require "carps/crypt/mailer"
require "carps/crypt/mailbox"

require "yaml"

class Hash
   # Like member? but for array of members.
   def members? elements
      present = elements.map {|field| member? field}
      present.all?
   end
end

module CARPS

   # Class to read email config.
   class EmailConfig < SystemConfig

      def EmailConfig.filepath
         "email.yaml"
      end

      def initialize address, same_pass, imap_options, smtp_options
         load_resources address, same_pass, imap_options, smtp_options
      end

      # Parse the email config file
      def parse_yaml conf
         address = read_conf conf, "address"
         same_pass = read_conf conf, "same_pass"
         imap = read_conf conf, "imap"
         unless imap.members?(["user", "server", "port", "tls", "certificate", "verify", "login", "cram_md5"])
            raise Expected, "Expected IMAP section to be valid."
         end
         smtp = read_conf conf, "smtp"
         unless smtp.members?(["user", "server", "port", "tls", "starttls", "login", "cram_md5"])
            raise Expected, "Expected SMTP section to be valid."
         end
         [address, same_pass, imap, smtp]        
      end

      # Connect to the imap and smtp servers
      def load_resources address, same_pass, imap_settings, smtp_settings
         @file_struct = {"address" => address, "same_pass" => same_pass, "imap" => imap_settings, "smtp" => smtp_settings}
         @address = address
         smtp_password = ""
         imap_password = ""
         if same_pass
            imap_password = smtp_password = UI::secret("Enter password for #{address}:")
         else
            imap_password = UI::secret "Enter password for IMAP account at #{address}:"
            smtp_password = UI::secret "Enter password for SMTP account at #{address}:"
         end
         @imap = IMAP.new imap_settings, imap_password
         @smtp = SMTP.new smtp_settings, smtp_password
      end

      # Relentlessly continue until we can connect to IMAP and SMTP
      def connect!
         @smtp.with_connection {|smtp|}
         @imap.with_connection {|imap|}
      end

      # Emit options as hash
      def emit
         @file_struct
      end

      # Expose the IMAP client
      def imap
         @imap
      end

      # Expose the SMTP client
      def smtp
         @smtp
      end

      # Return the high level mail client
      def mailer message_parser, session_manager
         mailbox = Mailbox.new @smtp, @imap, message_parser, session_manager
         Mailer.new @address, mailbox
      end

   end

end
