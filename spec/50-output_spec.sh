#
# 50-output_spec.sh
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

% TESTDIR: "$SHELLSPEC_TMPBASE/dir-index-sh/output"
% FIXTURE: "$SHELLSPEC_HELPERDIR/fixture"

Describe "Output"
	setup() { rm -rf "$TESTDIR"; mkdir -p "$TESTDIR"; }
	teardown() { rm -rf "$TESTDIR"; }
	has_order() {
		value="${has_order:?}"
		format="$1"
		len=
		prefix=
		shift
		for i; do
			case "$format" in
				xml)
					prefix="${value%%>"${i%/}"</*}"
					;;
				json)
					prefix="${value%%\"name\":\""${i%/}"\"*}"
					;;
				*)
					prefix="${value%%>"$i"</*}"
					;;
			esac
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
	Path testdir-index="$TESTDIR/index.html"

	Describe "name"
		It "should generate index.html by default"
			When run source "$SCRIPT" "$TESTDIR"

			The status should be success
			The path testdir-index should be a file
			The path testdir-index should not be an empty file
		End

		It "should use the given file name with -o"
			When run source "$SCRIPT" -o foobar "$TESTDIR"

			The status should be success
			The path "$TESTDIR/foobar" should be a file
			The path "$TESTDIR/foobar" should not be an empty file
		End
	End

	Describe "format"
		setup_testdir() { touch "$TESTDIR/file"; mkdir "$TESTDIR/dir"; }
		BeforeEach "setup_testdir"
		Path xml-index="$TESTDIR/index.xml"
		Path json-index="$TESTDIR/index.json"
		Path dir-index="$TESTDIR/dir/index.html"
		Path xml-dir-index="$TESTDIR/dir/index.xml"
		Path json-dir-index="$TESTDIR/dir/index.json"

		It "should generate an HTML index file by default"
			When run source "$SCRIPT" "$TESTDIR"

			The status should be success
			The path testdir-index should be a file
			The path testdir-index should not be an empty file

			The contents of path testdir-index should start with "<!DOCTYPE html>"
			The contents of path testdir-index should include ">file</a>"
			The contents of path testdir-index should include ">dir/</a>"
			The contents of path testdir-index should include "</html>"

			The path dir-index should be a file
			The path dir-index should not be an empty file

			The contents of path dir-index should start with "<!DOCTYPE html>"
			The contents of path dir-index should include "</html>"
		End

		It "should generate an HTML index file with -O html"
			When run source "$SCRIPT" -O html "$TESTDIR"

			The status should be success
			The path testdir-index should be a file
			The path testdir-index should not be an empty file

			The contents of path testdir-index should start with "<!DOCTYPE html>"
			The contents of path testdir-index should include ">file</a>"
			The contents of path testdir-index should include ">dir/</a>"
			The contents of path testdir-index should include "</html>"

			The path dir-index should be a file
			The path dir-index should not be an empty file

			The contents of path dir-index should start with "<!DOCTYPE html>"
			The contents of path dir-index should include "</html>"
		End

		It "should generate an XML index file with -O xml"
			When run source "$SCRIPT" -O xml "$TESTDIR"

			The status should be success
			The path xml-index should be a file
			The path xml-index should not be an empty file

			The contents of path xml-index should start with "<?xml version=\"1.0\" encoding=\"UTF-8\"?><list>"
			The contents of path xml-index should include ">file</file>"
			The contents of path xml-index should include ">dir</directory>"
			The contents of path xml-index should include "</list>"

			The path xml-dir-index should be a file
			The path xml-dir-index should not be an empty file

			The contents of path xml-dir-index should start with "<?xml version=\"1.0\" encoding=\"UTF-8\"?><list></list>"
		End

		It "should generate a JSON index file with -O json"
			When run source "$SCRIPT" -O json "$TESTDIR"

			The status should be success
			The path json-index should be a file
			The path json-index should not be an empty file

			The contents of path json-index should start with "[{"
			The contents of path json-index should end with "}]"
			The contents of path json-index should include "\"name\":\"file\",\"type\":\"file\""
			The contents of path json-index should include "\"name\":\"dir\",\"type\":\"directory\""

			The path json-dir-index should be a file
			The path json-dir-index should not be an empty file

			The contents of path json-dir-index should equal "[]"
		End

		It "should show an error for an invalid output format"
			When run source "$SCRIPT" -O invalid "$TESTDIR"

			The status should be failure
			The error should equal "$SCRIPT_NAME: error: \"invalid\" is not a valid output format"
			The path testdir-index should not exist
		End
	End

	Describe "sort"
		Path testdir-index-common="$TESTDIR/index"

		Describe "primary by column"
			setup_testdir() {
				%printf '#' > "$TESTDIR/b"
				%sleep 1
				%printf '###' > "$TESTDIR/a"
				%sleep 1
				%printf '##' > "$TESTDIR/c"
			}
			BeforeEach "setup_testdir"

			Parameters:value html xml json

			It "should sort entries ascending by name by default ($1)"
				When run source "$SCRIPT" -o index -O "$1" "$TESTDIR"

				The status should be success
				The path testdir-index-common should be a file
				The path testdir-index-common should not be an empty file

				The contents of path testdir-index-common should satisfy has_order "$1" a b c
			End

			It "should sort entries ascending by name with -S asc ($1)"
				When run source "$SCRIPT" -o index -O "$1" -S asc "$TESTDIR"

				The status should be success
				The path testdir-index-common should be a file
				The path testdir-index-common should not be an empty file

				The contents of path testdir-index-common should satisfy has_order "$1" a b c
			End

			It "should sort entries descending by name with -S desc ($1)"
				When run source "$SCRIPT" -o index -O "$1" -S desc "$TESTDIR"

				The status should be success
				The path testdir-index-common should be a file
				The path testdir-index-common should not be an empty file

				The contents of path testdir-index-common should satisfy has_order "$1" c b a
			End

			It "should sort entries ascending by name with -s name ($1)"
				When run source "$SCRIPT" -o index -O "$1" -s name "$TESTDIR"

				The status should be success
				The path testdir-index-common should be a file
				The path testdir-index-common should not be an empty file

				The contents of path testdir-index-common should satisfy has_order "$1" a b c
			End

			It "should sort entries ascending by name with -s name -S asc ($1)"
				When run source "$SCRIPT" -o index -O "$1" -s name -S asc "$TESTDIR"

				The status should be success
				The path testdir-index-common should be a file
				The path testdir-index-common should not be an empty file

				The contents of path testdir-index-common should satisfy has_order "$1" a b c
			End

			It "should sort entries descending by name with -s name -S desc ($1)"
				When run source "$SCRIPT" -o index -O "$1" -s name -S desc "$TESTDIR"

				The status should be success
				The path testdir-index-common should be a file
				The path testdir-index-common should not be an empty file

				The contents of path testdir-index-common should satisfy has_order "$1" c b a
			End

			It "should sort entries ascending by last modified with -s modified ($1)"
				When run source "$SCRIPT" -o index -O "$1" -s modified "$TESTDIR"

				The status should be success
				The path testdir-index-common should be a file
				The path testdir-index-common should not be an empty file

				The contents of path testdir-index-common should satisfy has_order "$1" b a c
			End

			It "should sort entries ascending by last modified with -s modified -S asc ($1)"
				When run source "$SCRIPT" -o index -O "$1" -s modified -S asc "$TESTDIR"

				The status should be success
				The path testdir-index-common should be a file
				The path testdir-index-common should not be an empty file

				The contents of path testdir-index-common should satisfy has_order "$1" b a c
			End

			It "should sort entries descending by last modified with -s modified -S desc ($1)"
				When run source "$SCRIPT" -o index -O "$1" -s modified -S desc "$TESTDIR"

				The status should be success
				The path testdir-index-common should be a file
				The path testdir-index-common should not be an empty file

				The contents of path testdir-index-common should satisfy has_order "$1" c a b
			End

			It "should sort entries ascending by size with -s size ($1)"
				When run source "$SCRIPT" -o index -O "$1" -s size "$TESTDIR"

				The status should be success
				The path testdir-index-common should be a file
				The path testdir-index-common should not be an empty file

				The contents of path testdir-index-common should satisfy has_order "$1" b c a
			End

			It "should sort entries ascending by size with -s size -S asc ($1)"
				When run source "$SCRIPT" -o index -O "$1" -s size -S asc "$TESTDIR"

				The status should be success
				The path testdir-index-common should be a file
				The path testdir-index-common should not be an empty file

				The contents of path testdir-index-common should satisfy has_order "$1" b c a
			End

			It "should sort entries descending by size with -s size -S desc ($1)"
				When run source "$SCRIPT" -o index -O "$1" -s size -S desc "$TESTDIR"

				The status should be success
				The path testdir-index-common should be a file
				The path testdir-index-common should not be an empty file

				The contents of path testdir-index-common should satisfy has_order "$1" a c b
			End
		End

		Describe "secondary by name"
			setup_testdir() { touch "$TESTDIR/b"; touch "$TESTDIR/a"; }
			BeforeEach "setup_testdir"

			Parameters:value html xml json

			It "should sort entries ascending by name after primary sort ($1)"
				When run source "$SCRIPT" -o index -O "$1" -s size "$TESTDIR"

				The status should be success
				The path testdir-index-common should be a file
				The path testdir-index-common should not be an empty file

				The contents of path testdir-index-common should satisfy has_order "$1" a b
			End

			It "should sort entries ascending by name after primary sort with -S asc ($1)"
				When run source "$SCRIPT" -o index -O "$1" -s size -S asc "$TESTDIR"

				The status should be success
				The path testdir-index-common should be a file
				The path testdir-index-common should not be an empty file

				The contents of path testdir-index-common should satisfy has_order "$1" a b
			End

			It "should sort entries descending by name after primary sort with -S desc ($1)"
				When run source "$SCRIPT" -o index -O "$1" -s size -S desc "$TESTDIR"

				The status should be success
				The path testdir-index-common should be a file
				The path testdir-index-common should not be an empty file

				The contents of path testdir-index-common should satisfy has_order "$1" b a
			End
		End

		Describe "version sort"
			setup_testdir() { for i in 2.10 2.2 10 1; do touch "$TESTDIR/$i"; done; }
			BeforeEach "setup_testdir"

			Parameters:value html xml json

			It "should sort entries with version sort enabled ascending by name by default ($1)"
				When run source "$SCRIPT" -o index -O "$1" "$TESTDIR"

				The status should be success
				The path testdir-index-common should be a file
				The path testdir-index-common should not be an empty file

				The contents of path testdir-index-common should satisfy has_order "$1" 1 2.2 2.10 10
			End

			It "should sort entries with version sort enabled ascending by name with -S version ($1)"
				When run source "$SCRIPT" -o index -O "$1" -S version "$TESTDIR"

				The status should be success
				The path testdir-index-common should be a file
				The path testdir-index-common should not be an empty file

				The contents of path testdir-index-common should satisfy has_order "$1" 1 2.2 2.10 10
			End

			It "should sort entries with version sort enabled ascending by name with -S asc,version ($1)"
				When run source "$SCRIPT" -o index -O "$1" -S asc,version "$TESTDIR"

				The status should be success
				The path testdir-index-common should be a file
				The path testdir-index-common should not be an empty file

				The contents of path testdir-index-common should satisfy has_order "$1" 1 2.2 2.10 10
			End

			It "should sort entries with version sort enabled descending by name with -S desc,version ($1)"
				When run source "$SCRIPT" -o index -O "$1" -S desc,version "$TESTDIR"

				The status should be success
				The path testdir-index-common should be a file
				The path testdir-index-common should not be an empty file

				The contents of path testdir-index-common should satisfy has_order "$1" 10 2.10 2.2 1
			End

			It "should sort entries with version sort disabled ascending by name with -S no-version ($1)"
				When run source "$SCRIPT" -o index -O "$1" -S no-version "$TESTDIR"

				The status should be success
				The path testdir-index-common should be a file
				The path testdir-index-common should not be an empty file

				The contents of path testdir-index-common should satisfy has_order "$1" 1 10 2.10 2.2
			End

			It "should sort entries with version sort disabled ascending by name with -S asc,no-version ($1)"
				When run source "$SCRIPT" -o index -O "$1" -S asc,no-version "$TESTDIR"

				The status should be success
				The path testdir-index-common should be a file
				The path testdir-index-common should not be an empty file

				The contents of path testdir-index-common should satisfy has_order "$1" 1 10 2.10 2.2
			End

			It "should sort entries with version sort disabled descending by name with -S desc,no-version ($1)"
				When run source "$SCRIPT" -o index -O "$1" -S desc,no-version "$TESTDIR"

				The status should be success
				The path testdir-index-common should be a file
				The path testdir-index-common should not be an empty file

				The contents of path testdir-index-common should satisfy has_order "$1" 2.2 2.10 10 1
			End
		End

		Describe "case sensitivity"
			setup_testdir() { for i in aa Ab ba Bb; do touch "$TESTDIR/$i"; done; }
			BeforeEach "setup_testdir"
			BeforeEach "export LC_ALL=C"

			Describe "version sort enabled"
				Parameters:value html xml json

				It "should sort entries lexically (-S no-case has no effect) ($1)"
					When run source "$SCRIPT" -o index -O "$1" -S no-case "$TESTDIR"

					The status should be success
					The path testdir-index-common should be a file
					The path testdir-index-common should not be an empty file

					The contents of path testdir-index-common should satisfy has_order "$1" Ab Bb aa ba
				End
			End

			Describe "version sort disabled (-S no-version)"
				Parameters:value html xml json

				It "should sort entries ascending in case-sensitive manner by default ($1)"
					When run source "$SCRIPT" -o index -O "$1" -S no-version "$TESTDIR"

					The status should be success
					The path testdir-index-common should be a file
					The path testdir-index-common should not be an empty file

					The contents of path testdir-index-common should satisfy has_order "$1" Ab Bb aa ba
				End

				It "should sort entries ascending in case-sensitive manner with -S case ($1)"
					When run source "$SCRIPT" -o index -O "$1" -S no-version,case "$TESTDIR"

					The status should be success
					The path testdir-index-common should be a file
					The path testdir-index-common should not be an empty file

					The contents of path testdir-index-common should satisfy has_order "$1" Ab Bb aa ba
				End

				It "should sort entries ascending in case-sensitive manner with -S asc,case ($1)"
					When run source "$SCRIPT" -o index -O "$1" -S asc,no-version,case "$TESTDIR"

					The status should be success
					The path testdir-index-common should be a file
					The path testdir-index-common should not be an empty file

					The contents of path testdir-index-common should satisfy has_order "$1" Ab Bb aa ba
				End

				It "should sort entries descending in case-sensitive manner with -S desc,case ($1)"
					When run source "$SCRIPT" -o index -O "$1" -S desc,no-version,case "$TESTDIR"

					The status should be success
					The path testdir-index-common should be a file
					The path testdir-index-common should not be an empty file

					The contents of path testdir-index-common should satisfy has_order "$1" ba aa Bb Ab
				End

				It "should sort entries ascending in case-insensitive manner with -S no-case ($1)"
					When run source "$SCRIPT" -o index -O "$1" -S no-version,no-case "$TESTDIR"

					The status should be success
					The path testdir-index-common should be a file
					The path testdir-index-common should not be an empty file

					The contents of path testdir-index-common should satisfy has_order "$1" aa Ab ba Bb
				End

				It "should sort entries ascending in case-insensitive manner with -S asc,no-case ($1)"
					When run source "$SCRIPT" -o index -O "$1" -S asc,no-version,no-case "$TESTDIR"

					The status should be success
					The path testdir-index-common should be a file
					The path testdir-index-common should not be an empty file

					The contents of path testdir-index-common should satisfy has_order "$1" aa Ab ba Bb
				End

				It "should sort entries descending in case-insensitive manner with -S desc,no-case ($1)"
					When run source "$SCRIPT" -o index -O "$1" -S desc,no-version,no-case "$TESTDIR"

					The status should be success
					The path testdir-index-common should be a file
					The path testdir-index-common should not be an empty file

					The contents of path testdir-index-common should satisfy has_order "$1" Bb ba Ab aa
				End
			End
		End

		Describe "folders first"
			setup_testdir() {
				touch "$TESTDIR/a"; touch "$TESTDIR/c"
				mkdir "$TESTDIR/b"; mkdir "$TESTDIR/d"
			}
			BeforeEach "setup_testdir"

			Parameters:value html xml json

			It "should sort files and directories together by default ($1)"
				When run source "$SCRIPT" -o index -O "$1" "$TESTDIR"

				The status should be success
				The path testdir-index-common should be a file
				The path testdir-index-common should not be an empty file

				The contents of path testdir-index-common should satisfy has_order "$1" a b/
			End

			It "should sort files and directories together with -S no-folders-first ($1)"
				When run source "$SCRIPT" -o index -O "$1" -S no-folders-first "$TESTDIR"

				The status should be success
				The path testdir-index-common should be a file
				The path testdir-index-common should not be an empty file

				The contents of path testdir-index-common should satisfy has_order "$1" a b/ c d/
			End

			It "should sort ascending directories before files with -S folders-first ($1)"
				When run source "$SCRIPT" -o index -O "$1" -S folders-first "$TESTDIR"

				The status should be success
				The path testdir-index-common should be a file
				The path testdir-index-common should not be an empty file

				The contents of path testdir-index-common should satisfy has_order "$1" b/ d/ a c
			End

			It "should sort ascending directories before files with -S asc,folders-first ($1)"
				When run source "$SCRIPT" -o index -O "$1" -S asc,folders-first "$TESTDIR"

				The status should be success
				The path testdir-index-common should be a file
				The path testdir-index-common should not be an empty file

				The contents of path testdir-index-common should satisfy has_order "$1" b/ d/ a c
			End

			It "should sort descending directories before files with -S desc,folders-first ($1)"
				When run source "$SCRIPT" -o index -O "$1" -S desc,folders-first "$TESTDIR"

				The status should be success
				The path testdir-index-common should be a file
				The path testdir-index-common should not be an empty file

				The contents of path testdir-index-common should satisfy has_order "$1" d/ b/ c a
			End
		End

		Describe "errors"
			Parameters:value html xml json

			It "should show an error for an invalid sort column ($1)"
				When run source "$SCRIPT" -o index -O "$1" -s invalid "$TESTDIR"

				The status should be failure
				The error should equal "$SCRIPT_NAME: error: \"invalid\" is not a valid sort column"
				The path testdir-index-common should not exist
			End

			It "should show an error for an invalid sort option ($1)"
				When run source "$SCRIPT" -o index -O "$1" -S invalid "$TESTDIR"

				The status should be failure
				The error should equal "$SCRIPT_NAME: error: \"invalid\" is not a valid sort option"
				The path testdir-index-common should not exist
			End
		End
	End

	Describe "directory mtimes"
		is_unmodified() {
			dir="${is_unmodified:?}"
			dir_mtime="$(date -r "$dir" +%s)"
			ref_mtime="$(date -r "$dir/ref" +%s)"
			[ "$dir_mtime" -eq "$ref_mtime" ]
		}
		setup_testdir() {
			touch "$TESTDIR/ref"
			mkdir "$TESTDIR/dir"
			touch "$TESTDIR/dir/ref"
			touch -m -r "$TESTDIR" "$TESTDIR/ref"
			touch -m -r "$TESTDIR/dir" "$TESTDIR/dir/ref"
			%sleep 1
		}
		BeforeEach "setup_testdir"

		It "should preserve directory modification times by default"
			When run source "$SCRIPT" "$TESTDIR"

			The status should be success

			The path "$TESTDIR" should satisfy is_unmodified
			The path "$TESTDIR/dir" should satisfy is_unmodified
		End

		It "should update directory modification times with -F"
			When run source "$SCRIPT" -F "$TESTDIR"

			The status should be success

			The path "$TESTDIR" should not satisfy is_unmodified
			The path "$TESTDIR/dir" should not satisfy is_unmodified
		End
	End
End
