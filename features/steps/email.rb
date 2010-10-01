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
   imap_options = {"user" => "carps", "server" => "killersmurf.com" , "tls" => true, "port" => 993}
   smtp_options = imap_options.clone
   smtp_options["starttls"] = true
   smtp_options["tls"] = false
   smtp_options["port"] = 25
   $email_config = EmailConfig.new "carps@killersmurf.com", true, imap_options, smtp_options
   $email_config.connect!
end

Then /^an email is sent$/ do
   smtp = $email_config.smtp
   smtp.send $email_config.address, "It works!" 
end

Then /^an email is received$/ do
   puts "The email reads:"
   imap = $email_config.imap
   message = imap.read[0].to_s
   puts "Ruby encodes the message as: #{message.encoding.name}"
   puts message 
   puts "End email."
end
