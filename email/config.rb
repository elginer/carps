require "email/imap.rb"
require "email/smtp.rb"

require "util/error.rb"
require "util/config.rb"

require "yaml"

# Class to read email config.
class EmailConfig < YamlConfig

   # The first parameter is the config file to read
   # the second is the message_factory for parsing messages from email
   def initialize conf, message_factory
      imap_server = ""
      smtp_server = ""
      @username = ""
      password = ""
      email_file = nil

      # Try to read the email file
      begin
         email_file = File.read conf 
      rescue
         # On failure, write a message to stderr and exit
         fatal "Could not find email configuration file: email.yaml"
      end

      # Try to parse the file
      begin
         conf = YAML.load email_file

         @username = read_conf conf, "username"
         password = read_conf conf, "password"
         imap_server = read_conf conf, "imap"
         smtp_server = read_conf conf, "smtp"        

      rescue
         fatal "Error in email.yaml:\n#{$!}"
      end

      @imap = IMAP.new imap_server, username, password, message_factory
      @smtp = SMTP.new smtp_server, username, password
   end

   # Return the imap server
   def imap
      @imap
   end

   # Return the smtp server
   def smtp
      @smtp
   end

   # Return the user name
   def username
      @username
   end

end
