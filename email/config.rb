require "email/imap.rb"
require "email/smtp.rb"

require "util/error.rb"

require "yaml"

# Class to read email config.
class EmailConfig

   def initialize
      imap_server = ""
      smtp_server = ""
      username = ""
      password = ""
      email_file = nil

      # Try to read the email file
      begin
         email_file = File.read "email.yaml"
      rescue
         # On failure, write a message to stderr and exit
         fatal "Could not find email configuration file: email.yaml"
      end

      # Try to parse the file
      begin
         conf = YAML.load email_file

         # A little helper method
         def read_conf conf, field
            val = conf[field]
            if val == nil
               raise "Could not find field: #{field}"
            end
            val
         end

         username = read_conf conf, "username"
         password = read_conf conf, "password"
         imap_server = read_conf conf, "imap"
         smtp_server = read_conf conf, "smtp"        

      rescue
         fatal "Error in email.yaml:\n#{$!}"
      end

      @imap = IMAP.new imap_server, username, password
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

end
