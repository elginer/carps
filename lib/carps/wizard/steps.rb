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

require "carps/email/config"

require "carps/service/interface"

require "carps/util/process"
require "carps/util/editor"

require "carps/ui"

module CARPS

   module Setup

      # Base class for configuration steps
      #
      # Subclasses must:
      #
      # * do all real work in a 'test' method, after ensuring that the configuration is valid.
      #
      # * define a 'required' method which returns an array of 2 cell arrays pairing instance variables 
      # with the name of a command which would instantiate that variable.  This is so the mandatory command
      # can detect which options the user still needs to fill in.
      class Interface < CARPS::QuitInterface

         include ControlInterface

         def initialize
            super
            add_command :skip, "Skip this step."
            add_command :test, "Test that your settings are correct."
            add_command :done, "Proceed to the next step."
         end

         protected

         # Skip this step
         def skip
            @run = false
         end

         # An array of pairs of instance variables with the command required to fill that variable
         def required
            []
         end

         # See if all required files have been filled
         def mandatory testing=true
            not_present = required.reject do |var, name|
               var
            end
            missing_names = not_present.map {|var, name| name}
            if missing_names.empty?
               return true
            else
               msg = "You must run the following commands: " + missing_names.join(", ")
               if testing
                  test_failed msg
               else
                  UI::highlight msg
               end
               return false
            end
         end

         def help
            UI::highlight description
            super
            mandatory false
         end

         # This completes the configuration.
         #
         # Cannot be executed unless a test has just been passed.
         def done
            if @passed
               @run = false
            else
               UI::put_error "The test must pass before configuration can continue."
            end
         end

         # The test has passed.
         def test_passed
            UI::highlight "Test passed!"
            puts "If you are finished, you may proceed by running 'done'."
            @passed = true
         end

         # The test has failed.
         def test_failed reason=nil
            UI::put_error "Test failed."
            if reason
               puts reason
            end
            @passed = false
         end

         # There can sometimes be more than one reason why the test has failed.
         #
         # DEPRICATED use Test::multi_fail
         def multi_fail *reasons
            Test::multi_fail reasons
         end

         def repl
            @run = true
            while @run
               rep
            end
         end

         # The argument must be either yes or no.  Pass the argument and two procs, the first is executed on yes.
         def yes_no opt, yes, no
            if opt == "yes"
               yes.call
            elsif opt == "no"
               no.call
            else
               UI::put_error "Argument must be either 'yes' or 'no'"
            end
         end

      end

      # Configure email
      class Email < Interface

         def initialize
            super
            add_command "address", "Set your email address", "ADDRESS"
            add_command "user", "Sets your username for both SMTP and IMAP.", "USERNAME"
            add_command "server", "Sets your server for both SMTP and IMAP.", "SERVER"
            add_command "same_password", "You use the same password for both SMTP and IMAP. Default: yes.", "yes/no"
            add_command "smtp_server", "Sets your SMTP server.", "SERVER_ADDRESS"
            add_command "smtp_port", "The SMTP server's port. Default is 25.", "PORT"
            add_command "smtp_user", "Sets your username for SMTP only.", "USERNAME"
            add_command "smtp_auth", 
               "Configure authentication mechanism for your SMTP account\n" + options("plain", "plain", "login", "cram_md5"), "AUTHENTICATION"
            add_command "smtp_crypt", "Configure encryption for your SMTP account\n" + options("none", "none", "tls", "starttls"), "SECURITY"
            add_command "imap_server", "Sets your IMAP server.", "SERVER_ADDRESS"
            add_command "imap_port", "The IMAP server's port.  Default is 143." , "PORT"
            add_command "imap_user", "Sets your username for IMAP only.", "USERNAME"
            add_command "imap_auth", 
               "Configure authentication mechanism for your IMAP account\n" + options("plain", "plain", "login", "cram_md5"), "AUTHENTICATION"

            add_command "imap_crypt", 
               "Configure encryption for your IMAP account.\n" + options("none", "none", "tls"), 
               "SECURITY"
            add_command "imap_cert", "Set the certificate for your IMAP account.", "PATH_TO_CERTIFICATE"
            add_command "imap_no_cert", "Don't use a certificate for your IMAP account."
            add_command "imap_verify", "Verify the authenticity of your IMAP provider using certificates. Default: no.", "yes/no" 
            @same_pass = true 
            @smtp_port = 25
            @smtp_starttls = false
            @smtp_tls = false
            @smtp_login = false
            @smtp_cram_md5 = false
            @imap_port = 143
            @imap_tls = false
            @imap_login = false
            @imap_cram_md5 = false
            @imap_verify = false
         end

         def description
            "Configure your email account settings."
         end

         protected

         # Provide a string of options
         def options defa, *opts
            out = "Options are:\n\t"
            out += opts.join("\n\t\tor\n\t")
            out += "\nDefault: #{defa}"
            out
         end

         # Run the block if the string matches a valid authentication mechanism
         def with_valid_auth mech
            mech.downcase!
            if mech == "plain"
               yield :plain
            elsif mech == "login"
               yield :login
            elsif mech == "cram_md5"
               yield :cram_md5
            else
               UI::put_error "Unsupported mechanism.  Supported: plain, login, cram_md5"
            end
         end

         def smtp_auth mech
            with_valid_auth mech do |type|
               if type == :plain
                  @smtp_login = false
                  @smtp_cram_md5 = false
               elsif type == :login
                  @smtp_login = true
                  @smtp_cram_md5 = false
               elsif type == :cram_md5
                  @smtp_login = false
                  @smtp_cram_md5 = true
               end
            end
         end

         def imap_auth mech
            with_valid_auth mech do |type|
               if type == :plain
                  @imap_login = false
                  @imap_cram_md5 = false
               elsif type == :login
                  @imap_login = true
                  @imap_cram_md5 = false
               elsif type == :cram_md5
                  @imap_login = false
                  @imap_cram_md5 = true
               end
            end
         end

         def imap_no_cert
            @imap_cert = nil
         end

         def imap_cert filepath
            @imap_cert = filepath
         end

         def imap_verify opt
            yes_no opt, lambda {@imap_verify = true}, lambda {@imap_verify = false}
         end

         def server serv
            @smtp_server = serv
            @imap_server = serv
         end

         def same_password opt
            yes_no opt, lambda {@same_pass = true}, lambda {@same_pass = false}
         end

         def help
            super
         end

         def required
            [[@address, "address"], [@smtp_user, "user or smtp_user"], [@smtp_server, "server or smtp_server"], [@imap_user, "user or imap_user"], [@imap_server, "server or imap_server"]]
         end

         def test
            if mandatory
               smtp_options = {
                  "user" => @smtp_user, 
                  "server" => @smtp_server, 
                  "tls" => @smtp_tls, 
                  "starttls" => @smtp_starttls, 
                  "port" => @smtp_port,
                  "login" => @smtp_login,
                  "cram_md5" => @smtp_cram_md5
               }
               imap_options = {
                  "user" => @imap_user, 
                  "server" => @imap_server, 
                  "tls" => @imap_tls, 
                  "port" => @imap_port,
                  "login" => @imap_login,
                  "cram_md5" => @imap_cram_md5,
                  "certificate" => @imap_cert,
                  "verify" => @imap_verify
               }
               config = EmailConfig.new @address, @same_pass, imap_options, smtp_options
               puts config.emit.to_yaml
               good = UI::confirm "Are the above settings correct?"
               if good
                  if config.imap.ok? and config.smtp.ok?
                     config.save
                     test_passed
                  end
               end
            end
         end

         def imap_server server
            @imap_server = server
         end

         def smtp_server server
            @smtp_server = server
         end

         def imap_port pst
            with_valid_port pst do |port|
               @imap_port = port
            end
         end

         def smtp_port pst
            with_valid_port pst do |port|
               @smtp_port = port
            end
         end

         def imap_crypt option
            option.downcase!
            if option == "tls"
               @imap_tls = true
            elsif option == "none"
               @imap_tls = false
            else
               UI::put_error "Unsupported encryption scheme."
            end
         end

         def smtp_crypt option
            option.downcase!
            if option == "tls"
               @smtp_starttls = false
               @smtp_tls = true
            elsif option == "starttls"
               @smtp_starttls = true
               @smtp_tls = false
            elsif option == "none"
               @smtp_starttls = false
               @smtp_tls = false
            else
               UI::put_error "Unsupported encryption scheme."
            end

         end

         def smtp_user user
            @smtp_user = user
         end

         def imap_user user
            @imap_user = user
         end

         def address addr
            valid = addr.match /^.+\@(.+)$/
               if valid
                  @address = addr
               else
                  UI::put_error "Invalid email address."
               end
         end

         def user login
            smtp_user login
            imap_user login
         end

      end

      # Configure processing
      class Process < Interface

         def initialize
            super
            add_raw_command :terminal, "Specify a command used to launch interactive CARPS sub-programs, typically in another window.\n\tIE., a command which would run a program in a new X-windows terminal editor, or Screen session.\n\tUse %cmd in place of the sub-program to be executed\n\tExamples:\n\t\turxvt -e %cmd", "TERMINAL"
            add_command :port, "Specify a TCP port which will be used for local inter-process communication.\n\tDefault: 51000", "PORT"
            add_command :wait, "The user states when the process is complete.\n\tUse this if you use screen, or if your terminal emulator forks into the background, as gnome-terminal does.\n\tDefault: no", "yes/no"
            @confirm = false
            @port = 51000
            @term = "%cmd"
         end

         def description
         "Choose a shell for launching sub-processes, and setup inter-process communication."
         end

         protected

         def wait onoff
            yes_no onoff,
               lambda {@confirm = true},
               lambda {@confirm = false}
         end

         def test
            if mandatory
               shell = CARPS::Process.new @term, @port, @confirm
               puts "You should see 'It works!' in the new window."
               mut = Test::Mutate.new
               test_ipc shell, mut
               if mut.working?
                  UI::highlight mut.works?
                  good = UI::confirm "Did it say 'It works!' in the new window?"
                  if good
                     shell.save
                     test_passed
                  else
                     general_fail
                  end
               else
                  general_fail
               end
            end
         end

         def port pst
            with_valid_port pst do |port|
               @port = port
            end
         end

         def terminal term
            @term = term
         end

         private

         def general_fail
            multi_fail "The new terminal is detaching itself into the background.", "Port #{@port} is unavailable."
         end

      end

      # Configure editor
      class Editor < Interface

         def initialize
            super
            add_raw_command :editor, "Specify a text editor.\n\tUse %f in place of the filepath.\n\t\tExample:\n\t\tgvim --nofork %f", "COMMAND"
            add_command :wait, "Wait until the user says the editor is finished.  This may be useful if your editor forks into the background.\nDefault: no", "yes/no"
            @confirm = false
         end

         def description
         "Choose a text editor for editing character sheets, etc."
         end

         protected

         def wait onoff
            yes_no onoff,
               lambda {@confirm = true},
               lambda {@confirm = false}
         end

         def editor command
            @editor = CARPS::Editor.new command, @confirm
         end

         def required
            [[@editor, "editor"]]
         end

         def test
            if mandatory
               pass = CARPS::Test::editor @editor
               if pass
                  @editor.save
                  test_passed
               end
            end
         end

         private

      end

   end

end

# Perform an action if the string describes a valid port number
def with_valid_port pst
   port = pst.to_i
   if port > 0 and port <= 65535
      yield port
   else
      puts "The port must be a natural number, greater than zero and less than 65535."
   end
end
