# Test email functionality

require "carps/email/config"

require "carps/ui/question"

require "yaml"

include CARPS

# Clone the original settings and apply the changes to create an array of new settings
def make_settings settings, changes
   changes.map do |field, val|
      new_setting = settings.clone
      new_setting[field] = val
      new_setting
   end
end

class EmailConfig

   def imap
      @imap
   end

   def smtp
      @smtp
   nd

   def address
      @address
   end

end

Given /^default IMAP settings$/ do
   $imap_options = {
      "user" => "carps", 
      "server" => "killersmurf.com", 
      "tls" => true, 
      "port" => 993, 
      "certificate" => nil,
      "verify" => false,
      "login" => false, 
      "cram_md5" => false}
end

Given /^default SMTP settings$/ do
   $smtp_options = {
      "login" => false,
      "cram_md5" => false,
      "starttls" => true,
      "tls" => false,
      "port" => 25,
      "user" => "carps",
      "server" => "killersmurf.com"}
end

Then /^attempt connections with various SMTP security settings$/ do
   pass = UI::secret "Enter SMTP password for #{$smtp_options["user"]}"
   log = ["login", true]
   cram = ["cram_md5", true]
   tls = ["tls", true]
   nostarttls = ["starttls", false]
   settings = make_settings $smtp_options, [log, cram, tls, nostarttls]
   settings.each do |setting|
      puts "Testing setting:"
      puts setting.to_yaml
      smtp = SMTP.new setting, pass
      smtp.ok?
   end
end

Then /^attempt connections with various IMAP security settings$/ do
   pass = UI::secret "Enter IMAP password for #{$imap_options["user"]}"
   log = ["login", true]
   cram = ["cram_md5", true]
   notls = ["tls", false]
   cert = ["certificate", "/home/spoon/cert"]
   verify = ["verify", true]
   settings = make_settings $imap_options, [log, cram, notls, cert, verify]
   settings.each do |setting|
      puts "Testing setting:"
      puts setting.to_yaml
      imap = IMAP.new setting, pass
      imap.ok?
   end
end


Given /^the email account$/ do


   $email_config = EmailConfig.new "carps@killersmurf.com", true, $imap_options, $smtp_options
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
