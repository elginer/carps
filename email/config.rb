require "email/imap.rb"
require "email/smtp.rb"

# Class to read email config.
class EmailConfig

   def initialize
      @imap = IMAP.new
      @smtp = SMTP.new
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
