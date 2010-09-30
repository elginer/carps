# Test email functionality

require "carps/email/config"

require "carps/util/question"

include CARPS

class EmailConfig

   def imap
      @imap
   end

   def smtp
      @smtp
   end

   def address
      @address
   end

end

Given /^the email account$/ do
   $email_config = EmailConfig.new
end

Then /^an email is sent$/ do
   $email_config.smtp.send $email_config.address, "It works!" 
end

Then /^an email is received$/ do
   puts "The email reads:"
   puts $email_config.imap.read.to_s
   puts "End email."
end
