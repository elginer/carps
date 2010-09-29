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

require "carps/mod/sheet_verifier"
require "carps/mod/sheet_editor"

module CARPS

   # Mod base class supporting character sheet verification
   #
   # Subclasses should override
   # schema, semantic_verifier
   class Mod

      protected

      # The semantic verifier
      def semantic_verifier
         UserVerifier.new
      end

      # The schema
      def schema
         {}
      end

      # Sheet editor
      def editor
         SheetEditor.new schema, semantic_verifier
      end

   end

end
