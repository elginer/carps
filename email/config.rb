require "email/imap.rb"
require "email/smtp.rb"

require "util/error.rb"
require "util/config.rb"

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
      @username = read_conf conf, "username"
      password = read_conf conf, "password"
      imap_server = read_conf conf, "imap"
      smtp_server = read_conf conf, "smtp"
      [imap_server, smtp_server, password]        
   end

   # Connect to the imap and smtp servers
   def load_resources imap_server, smtp_server, password 
      @imap = IMAP.new imap_server, @username, password, @message_parser
      @smtp = SMTP.new smtp_server, @username, password
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
