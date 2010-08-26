require "email/imap"
require "email/smtp"

require "util/error"
require "util/config"

require "service/mailer"

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
