#
# 10-general_spec.sh
# This file is part of dir-index.sh.
#
# Copyright (C) 2026  The dir-index.sh authors
# <https://github.com/jefferyto/dir-index.sh>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

% TESTDIR: "$SHELLSPEC_TMPBASE/dir-index-sh/general"
% FIXTURE: "$SHELLSPEC_HELPERDIR/fixture"

Describe "General"
	BeforeEach "setup_testdir"
	AfterEach "teardown_testdir"
	Path testdir-index="$TESTDIR/index.html"

	Describe "dependencies"
		It "should show an error if 'date' is missing"
			gdate() { :; }
			date() { :; }

			Mock uu-date
			End

			When run source "$SCRIPT" "$TESTDIR"

			The status should be failure
			The error should equal "$SCRIPT_NAME: error: cannot find coreutils date"
			The path testdir-index should not exist
		End

		It "should show an error if 'find' is missing"
			gfind() { :; }
			find() { :; }

			When run source "$SCRIPT" "$TESTDIR"

			The status should be failure
			The error should equal "$SCRIPT_NAME: error: cannot find findutils find"
			The path testdir-index should not exist
		End

		It "should show an error if 'jq' is missing"
			jq() { :; }

			When run source "$SCRIPT" "$TESTDIR"

			The status should be failure
			The error should equal "$SCRIPT_NAME: error: cannot find jq"
			The path testdir-index should not exist
		End

		It "should show an error if 'mktemp' is missing"
			gmktemp() { :; }
			mktemp() { :; }

			Mock uu-mktemp
			End

			When run source "$SCRIPT" "$TESTDIR"

			The status should be failure
			The error should equal "$SCRIPT_NAME: error: cannot find coreutils mktemp"
			The path testdir-index should not exist
		End

		It "should show an error if 'numfmt' is missing"
			gnumfmt() { :; }
			numfmt() { :; }

			Mock uu-numfmt
			End

			When run source "$SCRIPT" "$TESTDIR"

			The status should be failure
			The error should equal "$SCRIPT_NAME: error: cannot find coreutils numfmt"
			The path testdir-index should not exist
		End

		It "should show an error if 'readlink' is missing"
			greadlink() { :; }
			readlink() { :; }

			Mock uu-readlink
			End

			When run source "$SCRIPT" "$TESTDIR"

			The status should be failure
			The error should equal "$SCRIPT_NAME: error: cannot find coreutils readlink"
			The path testdir-index should not exist
		End

		It "should show an error if 'realpath' is missing"
			grealpath() { :; }
			realpath() { :; }

			Mock uu-realpath
			End

			When run source "$SCRIPT" "$TESTDIR"

			The status should be failure
			The error should equal "$SCRIPT_NAME: error: cannot find coreutils realpath"
			The path testdir-index should not exist
		End

		It "should show an error if 'sed' is missing"
			gsed() { :; }
			sed() { :; }

			When run source "$SCRIPT" "$TESTDIR"

			The status should be failure
			The error should equal "$SCRIPT_NAME: error: cannot find GNU sed"
			The path testdir-index should not exist
		End

		It "should show an error if 'sort' is missing"
			gsort() { :; }
			sort() { :; }

			Mock uu-sort
			End

			When run source "$SCRIPT" "$TESTDIR"

			The status should be failure
			The error should equal "$SCRIPT_NAME: error: cannot find coreutils sort"
			The path testdir-index should not exist
		End

		It "should show an error if 'touch' is missing"
			gtouch() { :; }
			touch() { :; }

			Mock uu-touch
			End

			When run source "$SCRIPT" "$TESTDIR"

			The status should be failure
			The error should equal "$SCRIPT_NAME: error: cannot find coreutils touch"
			The path testdir-index should not exist
		End

		It "should show an error if 'tr' is missing"
			gtr() { :; }
			tr() { :; }

			Mock uu-tr
			End

			When run source "$SCRIPT" "$TESTDIR"

			The status should be failure
			The error should equal "$SCRIPT_NAME: error: cannot find coreutils tr"
			The path testdir-index should not exist
		End

		It "should show an error if a temporary directory cannot be made"
			gmktemp() { :; }
			mktemp() {
				if [ "$1" = "--version" ]; then
					echo "coreutils"
					exit 0
				fi
				exit 1
			}

			Mock uu-mktemp
			End

			When run source "$SCRIPT" "$TESTDIR"

			The status should be failure
			The error should equal "$SCRIPT_NAME: error: cannot create temporary directory"
			The path testdir-index should not exist
		End
	End

	Describe "force"
		setup_example() { touch "$TESTDIR/index.html"; }
		BeforeEach "setup_example"

		It "should not overwrite existing files"
			When run source "$SCRIPT" "$TESTDIR"

			The status should be success
			The path testdir-index should be an empty file
		End

		It "should overwrite existing files with -f"
			When run source "$SCRIPT" -f "$TESTDIR"

			The status should be success
			The path testdir-index should be a file
			The path testdir-index should not be an empty file
		End
	End

	Describe "version"
		It "should be displayed with -V"
			When run source "$SCRIPT" -V

			The status should be success
			The output should start with "$PACKAGE_NAME"
		End
	End

	Describe "usage"
		It "should be displayed with -h"
			When run source "$SCRIPT" -h

			The status should be success
			The output should start with "Usage:"
		End

		It "should be displayed for an invalid command line option"
			When run source "$SCRIPT" -J

			The status should be failure
			The error should include "option"
			The error should include "J"
			The output should start with "Usage:"
		End
	End
End
