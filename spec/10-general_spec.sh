#
# 10-general_spec.sh
# This file is part of dir-index.sh.
#
# Copyright (C) 2026  The dir-index.sh authors
# <https://github.com/jefferyto/dir-index.sh>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, see <https://www.gnu.org/licenses/>.
#

% TESTDIR: "$SHELLSPEC_TMPBASE/dir-index-sh/general"
% FIXTURE: "$SHELLSPEC_HELPERDIR/fixture"

Describe "General"
	setup() { rm -rf "$TESTDIR"; mkdir -p "$TESTDIR"; }
	teardown() { rm -rf "$TESTDIR"; }
	BeforeEach "setup"
	AfterEach "teardown"
	Path testdir-index="$TESTDIR/index.html"

	Describe "dependencies"
		It "should show an error if 'date' is missing"
			gdate() { :; }
			date() { :; }

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

			When run source "$SCRIPT" "$TESTDIR"

			The status should be failure
			The error should equal "$SCRIPT_NAME: error: cannot find coreutils mktemp"
			The path testdir-index should not exist
		End

		It "should show an error if 'numfmt' is missing"
			gnumfmt() { :; }
			numfmt() { :; }

			When run source "$SCRIPT" "$TESTDIR"

			The status should be failure
			The error should equal "$SCRIPT_NAME: error: cannot find coreutils numfmt"
			The path testdir-index should not exist
		End

		It "should show an error if 'readlink' is missing"
			greadlink() { :; }
			readlink() { :; }

			When run source "$SCRIPT" "$TESTDIR"

			The status should be failure
			The error should equal "$SCRIPT_NAME: error: cannot find coreutils readlink"
			The path testdir-index should not exist
		End

		It "should show an error if 'realpath' is missing"
			grealpath() { :; }
			realpath() { :; }

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

			When run source "$SCRIPT" "$TESTDIR"

			The status should be failure
			The error should equal "$SCRIPT_NAME: error: cannot find coreutils sort"
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

			When run source "$SCRIPT" "$TESTDIR"

			The status should be failure
			The error should equal "$SCRIPT_NAME: error: cannot create temporary directory"
			The path testdir-index should not exist
		End
	End

	Describe "force"
		touch_index() { touch "$TESTDIR/index.html"; }
		BeforeEach "touch_index"

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
			When run source "$SCRIPT" -1

			The status should be failure
			The error should match pattern "*[Ii]llegal option*"
			The output should start with "Usage:"
		End
	End

	Describe "shellcheck"
		not_exists_shellcheck() { ! shellcheck --version >/dev/null 2>&1; }
		Skip if "ShellCheck not available" not_exists_shellcheck

		It "should pass ShellCheck"
			When run command shellcheck --rcfile="$SHELLSPEC_PROJECT_ROOT/.shellcheckrc" "$SCRIPT"

			The status should be success
		End
	End
End
