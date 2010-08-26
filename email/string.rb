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


# A special type of string used in mail
class MailString < String

   # Safely create a mail string
   def MailString.safe msg
      MailString.new MailString.mail_lines msg
   end

   # Join two strings into a new piece of mail text
   def + other
      MailString.new super MailString.mail_lines other
   end

   # If the second string is greater than 78 characters long
   # Split it into multiple lines
   # See http://www.faqs.org/rfcs/rfc2822.html
   def MailString.mail_lines msg
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
