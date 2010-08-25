# A special type of string used in mail
class MailString < String

   # Safely create a mail string
   def MailString.safe msg
      MailString.new mail_lines msg
   end

   # Join two strings into a new piece of mail text
   def + other
      MailString.new super mail_lines other
   end

   # If the second string is greater than 78 characters long
   # Split it into multiple lines
   # See http://www.faqs.org/rfcs/rfc2822.html
   def mail_lines msg
      msg = msg.gsub /\s/, " "
      lines = [msg]
      while lines.last.size > 78
         top = lines.last
         lines[lines.size - 1] = top[0 .. 77]
         lines.push top[78 .. -1]
      end
      lines.join crlf
   end

end

# Helps writing mail
def crlf
   "\r\n"
end
