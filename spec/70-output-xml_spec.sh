#
# 70-output-xml_spec.sh
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

% TESTDIR: "$SHELLSPEC_TMPBASE/dir-index-sh/output-xml"
% FIXTURE: "$SHELLSPEC_HELPERDIR/fixture"

Describe "XML output"
	setup() { rm -rf "$TESTDIR"; mkdir -p "$TESTDIR"; }
	teardown() { rm -rf "$TESTDIR"; }
	has_order() {
		value="${has_order:?}"
		len=
		prefix=
		for i; do
			prefix="${value%%>"$i"</*}"
			if [ "$prefix" = "$value" ]; then
				return 1
			fi
			if [ -n "$len" ] && [ "${#prefix}" -lt "$len" ]; then
				return 1
			fi
			len="${#prefix}"
		done
		return 0
	}
	BeforeEach "setup"
	AfterEach "teardown"
	Path testdir-index="$TESTDIR/index.xml"

	Describe "XML encoding"
		It "should use \"UTF-8\" as the encoding by default"
			When run source "$SCRIPT" -O xml "$TESTDIR"

			The status should be success
			The path testdir-index should be a file
			The path testdir-index should not be an empty file

			The contents of path testdir-index should start with "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
		End

		It "should use an escaped custom encoding with -G"
			When run source "$SCRIPT" -O xml -G "foo & bar" "$TESTDIR"

			The status should be success
			The path testdir-index should be a file
			The path testdir-index should not be an empty file

			The contents of path testdir-index should start with "<?xml version=\"1.0\" encoding=\"foo &amp; bar\"?>"
		End
	End

	Describe "index entries"
		Describe "no entries"
			It "should output an empty list"
				When run source "$SCRIPT" -O xml "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should include "<list></list>"
			End
		End

		Describe "files"
			setup_testdir() {
				cp "$FIXTURE/compressed.png" "$TESTDIR/file.txt"
				touch -m -d "2099-07-08T12:34:56Z" "$TESTDIR/file.txt"
			}
			BeforeEach "setup_testdir"

			It "should output <file> element"
				When run source "$SCRIPT" -O xml "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should include "<file "
			End

			It "should set mtime attribute"
				When run source "$SCRIPT" -O xml "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should include " mtime=\"2099-07-08T12:34:56.000000000Z\""
			End

			It "should set size attribute"
				When run source "$SCRIPT" -O xml "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should include " size=\"1108\""
			End

			It "should use file name as element content"
				When run source "$SCRIPT" -O xml "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should include ">file.txt</file>"
			End
		End

		Describe "directories"
			setup_testdir() {
				mkdir "$TESTDIR/dir"
				touch -m -d "2099-07-08T12:34:56Z" "$TESTDIR/dir"
			}
			BeforeEach "setup_testdir"

			It "should output <directory> element"
				When run source "$SCRIPT" -O xml "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should include "<directory "
			End

			It "should set mtime attribute"
				When run source "$SCRIPT" -O xml "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should include " mtime=\"2099-07-08T12:34:56.000000000Z\""
			End

			It "should not set size attribute"
				When run source "$SCRIPT" -O xml "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should not include " size="
			End

			It "should use directory name as element content"
				When run source "$SCRIPT" -O xml "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should include ">dir</directory>"
			End
		End
	End

	Describe "XML escaping"
		Parameters
			"double quotes" '"' "&quot;"
			"ampersand"     "&" "&amp;"
			"single quote"  "'" "&apos;"
			"less than"     "<" "&lt;"
			"greater than"  ">" "&gt;"
		End

		It "should escape $1"
			mkdir "$TESTDIR/$2"

			When run source "$SCRIPT" -O xml "$TESTDIR"

			The status should be success
			The path testdir-index should be a file
			The path testdir-index should not be an empty file

			The contents of path testdir-index should include ">$3</directory>"
		End
	End
End
