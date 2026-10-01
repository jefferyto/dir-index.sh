#
# 20-indexing_spec.sh
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

% TESTDIR: "$SHELLSPEC_TMPBASE/dir-index-sh/indexing"
% FIXTURE: "$SHELLSPEC_HELPERDIR/fixture"

Describe "Indexing"
	setup() { rm -rf "$TESTDIR"; mkdir -p "$TESTDIR"; }
	teardown() { rm -rf "$TESTDIR"; }
	print0() { %printf '%s\0' "$@"; }
	BeforeEach "setup"
	AfterEach "teardown"
	Path testdir-index="$TESTDIR/index.html"

	Describe "root directories"
		Describe "source"
			setup_testdir() { for i in 1 2 3; do mkdir "$TESTDIR/dir$i"; done; }
			BeforeEach "setup_testdir"
			Path dir1-index="$TESTDIR/dir1/index.html"
			Path dir2-index="$TESTDIR/dir2/index.html"
			Path dir3-index="$TESTDIR/dir3/index.html"

			It "should index root directories from the command line"
				When run source "$SCRIPT" "$TESTDIR/dir1" "$TESTDIR/dir2" "$TESTDIR/dir3"

				The status should be success

				The path dir1-index should be a file
				The path dir1-index should not be an empty file

				The path dir2-index should be a file
				The path dir2-index should not be an empty file

				The path dir3-index should be a file
				The path dir3-index should not be an empty file
			End

			It "should index root directories from a file"
				print0 "$TESTDIR/dir1" "$TESTDIR/dir2" "$TESTDIR/dir3" > "$TESTDIR/list"

				When run source "$SCRIPT" -g "$TESTDIR/list"

				The status should be success

				The path dir1-index should be a file
				The path dir1-index should not be an empty file

				The path dir2-index should be a file
				The path dir2-index should not be an empty file

				The path dir3-index should be a file
				The path dir3-index should not be an empty file
			End

			It "should index root directories from standard input"
				Data print0 "$TESTDIR/dir1" "$TESTDIR/dir2" "$TESTDIR/dir3"

				When run source "$SCRIPT" -g -

				The status should be success

				The path dir1-index should be a file
				The path dir1-index should not be an empty file

				The path dir2-index should be a file
				The path dir2-index should not be an empty file

				The path dir3-index should be a file
				The path dir3-index should not be an empty file
			End
		End

		Describe "root directory path"
			abs_testdir="$(realpath "$TESTDIR")"

			Parameters
				"leading slash"  "$abs_testdir"
				"trailing slash" "$TESTDIR/"
				"leading /./"    "/./$abs_testdir"
				"trailing /./"   "$TESTDIR/./"
			End

			It "should index root directories with a $1 from the command line"
				When run source "$SCRIPT" "$2"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file
			End

			It "should index root directories with a $1 from a file"
				print0 "$2" > "$TESTDIR/list"

				When run source "$SCRIPT" -g "$TESTDIR/list"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file
			End

			It "should index root directories with a $1 from standard input"
				Data print0 "$2"

				When run source "$SCRIPT" -g -

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file
			End
		End

		Describe "warning/errors"
			It "should display usage for no root directories"
				When run source "$SCRIPT"

				The status should be failure
				The output should start with "Usage:"
			End

			It "should show a warning for an empty root directory"
				When run source "$SCRIPT" ""

				The status should be failure
				The error should equal "$SCRIPT_NAME: warning: not indexing empty path"
			End

			It "should show a warning for a nonexistent root directory"
				When run source "$SCRIPT" "$TESTDIR/nonexistent"

				The status should be failure
				The error should equal "$SCRIPT_NAME: warning: \"$TESTDIR/nonexistent\" is not an accessible directory"
			End

			It "should show a warning for a non-readable root directory"
				mkdir "$TESTDIR/dir"
				chmod a-r "$TESTDIR/dir"

				When run source "$SCRIPT" "$TESTDIR/dir"

				The status should be failure
				The error should equal "$SCRIPT_NAME: warning: \"$TESTDIR/dir\" is not an accessible directory"
			End

			It "should show a warning for a non-writeable root directory"
				mkdir "$TESTDIR/dir"
				chmod a-w "$TESTDIR/dir"

				When run source "$SCRIPT" "$TESTDIR/dir"

				The status should be failure
				The error should equal "$SCRIPT_NAME: warning: \"$TESTDIR/dir\" is not an accessible directory"
			End

			It "should show a warning for a non-executable root directory"
				mkdir "$TESTDIR/dir"
				chmod a-x "$TESTDIR/dir"

				When run source "$SCRIPT" "$TESTDIR/dir"

				The status should be failure
				The error should equal "$SCRIPT_NAME: warning: \"$TESTDIR/dir\" is not an accessible directory"
			End

			It "should show an error for a non-readable root directories file"
				When run source "$SCRIPT" -g "$TESTDIR/nonexistent"

				The status should be failure
				The error should equal "$SCRIPT_NAME: error: \"$TESTDIR/nonexistent\" is not a readable file"
			End
		End
	End

	Describe "ignore patterns"
		Describe "source"
			setup_testdir() {
				touch "$TESTDIR/file1"; touch "$TESTDIR/file2"
				mkdir "$TESTDIR/dir1"; mkdir "$TESTDIR/dir2"
			}
			BeforeEach "setup_testdir"

			It "should ignore files/directories that match patterns from the command line"
				When run source "$SCRIPT" -i "file1" -i "f???2" -i "dir1" -i "d*2" "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should not include ">file1</a>"
				The contents of path testdir-index should not include ">file2</a>"
				The contents of path testdir-index should not include ">dir1/</a>"
				The contents of path testdir-index should not include ">dir2/</a>"
			End

			It "should ignore files/directories that match patterns from a file"
				print0 "file1" "f???2" "dir1" "d*2" > "$TESTDIR/list"

				When run source "$SCRIPT" -I "$TESTDIR/list" "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should not include ">file1</a>"
				The contents of path testdir-index should not include ">file2</a>"
				The contents of path testdir-index should not include ">dir1/</a>"
				The contents of path testdir-index should not include ">dir2/</a>"
			End

			It "should ignore files/directories that match patterns from standard input"
				Data print0 "file1" "f???2" "dir1" "d*2"

				When run source "$SCRIPT" -I - "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should not include ">file1</a>"
				The contents of path testdir-index should not include ">file2</a>"
				The contents of path testdir-index should not include ">dir1/</a>"
				The contents of path testdir-index should not include ">dir2/</a>"
			End
		End

		Describe "options"
			Describe "dot files"
				setup_testdirs() { touch "$TESTDIR/.file"; mkdir "$TESTDIR/.dir"; }
				BeforeEach "setup_testdirs"

				It "should ignore dot files/directories by default"
					When run source "$SCRIPT" "$TESTDIR"

					The status should be success
					The path testdir-index should be a file
					The path testdir-index should not be an empty file

					The contents of path testdir-index should not include ">.file</a>"
					The contents of path testdir-index should not include ">.dir/</a>"
				End

				It "should ignore dot files/directories with -T ignore-dot"
					When run source "$SCRIPT" -T ignore-dot "$TESTDIR"

					The status should be success
					The path testdir-index should be a file
					The path testdir-index should not be an empty file

					The contents of path testdir-index should not include ">.file</a>"
					The contents of path testdir-index should not include ">.dir/</a>"
				End

				It "should not ignore dot files/directories with -T no-ignore-dot"
					When run source "$SCRIPT" -T no-ignore-dot "$TESTDIR"

					The status should be success
					The path testdir-index should be a file
					The path testdir-index should not be an empty file

					The contents of path testdir-index should include ">.file</a>"
					The contents of path testdir-index should include ">.dir/</a>"
				End
			End

			Describe "HTML includes"
				setup_testdir() { for i in HEAD HEADER README; do touch "$TESTDIR/$i"; done; }
				BeforeEach "setup_testdir"

				Describe "HTML output"
					It "should not ignore HTML include paths"
						When run source "$SCRIPT" -O html -E "$TESTDIR/HEAD" -D "$TESTDIR/HEADER" -R "$TESTDIR/README" "$TESTDIR"

						The status should be success
						The path testdir-index should be a file
						The path testdir-index should not be an empty file

						The contents of path testdir-index should include ">HEAD</a>"
						The contents of path testdir-index should include ">HEADER</a>"
						The contents of path testdir-index should include ">README</a>"
					End

					It "should ignore HTML include base name files by default"
						When run source "$SCRIPT" -O html -E HEAD -D HEADER -R README "$TESTDIR"

						The status should be success
						The path testdir-index should be a file
						The path testdir-index should not be an empty file

						The contents of path testdir-index should not include ">HEAD</a>"
						The contents of path testdir-index should not include ">HEADER</a>"
						The contents of path testdir-index should not include ">README</a>"
					End

					It "should ignore HTML include base name files with -T ignore-includes"
						When run source "$SCRIPT" -O html -T ignore-includes -E HEAD -D HEADER -R README "$TESTDIR"

						The status should be success
						The path testdir-index should be a file
						The path testdir-index should not be an empty file

						The contents of path testdir-index should not include ">HEAD</a>"
						The contents of path testdir-index should not include ">HEADER</a>"
						The contents of path testdir-index should not include ">README</a>"
					End

					It "should not ignore HTML include base name files with -T no-ignore-includes"
						When run source "$SCRIPT" -O html -T no-ignore-includes -E HEAD -D HEADER -R README "$TESTDIR"

						The status should be success
						The path testdir-index should be a file
						The path testdir-index should not be an empty file

						The contents of path testdir-index should include ">HEAD</a>"
						The contents of path testdir-index should include ">HEADER</a>"
						The contents of path testdir-index should include ">README</a>"
					End
				End

				Describe "XML output"
					Path xml-index="$TESTDIR/index.xml"

					It "should not ignore HTML include paths"
						When run source "$SCRIPT" -O xml -E "$TESTDIR/HEAD" -D "$TESTDIR/HEADER" -R "$TESTDIR/README" "$TESTDIR"

						The status should be success
						The path xml-index should be a file
						The path xml-index should not be an empty file

						The contents of path xml-index should include ">HEAD</file>"
						The contents of path xml-index should include ">HEADER</file>"
						The contents of path xml-index should include ">README</file>"
					End

					It "should not ignore HTML include base name files by default"
						When run source "$SCRIPT" -O xml -E HEAD -D HEADER -R README "$TESTDIR"

						The status should be success
						The path xml-index should be a file
						The path xml-index should not be an empty file

						The contents of path xml-index should include ">HEAD</file>"
						The contents of path xml-index should include ">HEADER</file>"
						The contents of path xml-index should include ">README</file>"
					End

					It "should not ignore HTML include base name files with -T ignore-includes"
						When run source "$SCRIPT" -O xml -T ignore-includes -E HEAD -D HEADER -R README "$TESTDIR"

						The status should be success
						The path xml-index should be a file
						The path xml-index should not be an empty file

						The contents of path xml-index should include ">HEAD</file>"
						The contents of path xml-index should include ">HEADER</file>"
						The contents of path xml-index should include ">README</file>"
					End
				End

				Describe "JSON output"
					Path json-index="$TESTDIR/index.json"

					It "should not ignore HTML include paths"
						When run source "$SCRIPT" -O json -E "$TESTDIR/HEAD" -D "$TESTDIR/HEADER" -R "$TESTDIR/README" "$TESTDIR"

						The status should be success
						The path json-index should be a file
						The path json-index should not be an empty file

						The contents of path json-index should include "\"name\":\"HEAD\""
						The contents of path json-index should include "\"name\":\"HEADER\""
						The contents of path json-index should include "\"name\":\"README\""
					End

					It "should not ignore HTML include base name files by default"
						When run source "$SCRIPT" -O json -E HEAD -D HEADER -R README "$TESTDIR"

						The status should be success
						The path json-index should be a file
						The path json-index should not be an empty file

						The contents of path json-index should include "\"name\":\"HEAD\""
						The contents of path json-index should include "\"name\":\"HEADER\""
						The contents of path json-index should include "\"name\":\"README\""
					End

					It "should not ignore HTML include base name files with -T ignore-includes"
						When run source "$SCRIPT" -O json -T ignore-includes -E HEAD -D HEADER -R README "$TESTDIR"

						The status should be success
						The path json-index should be a file
						The path json-index should not be an empty file

						The contents of path json-index should include "\"name\":\"HEAD\""
						The contents of path json-index should include "\"name\":\"HEADER\""
						The contents of path json-index should include "\"name\":\"README\""
					End
				End
			End

			Describe "multiple options"
				setup_testdirs() {
					touch "$TESTDIR/.file"; mkdir "$TESTDIR/.dir"
					for i in HEAD HEADER README; do touch "$TESTDIR/$i"; done
				}
				BeforeEach "setup_testdirs"

				It "should not ignore dot files/directories and not ignore HTML include base name files with -T no-ignore-dot,no-ignore-includes"
					When run source "$SCRIPT" -T no-ignore-dot,no-ignore-includes -E HEAD -D HEADER -R README "$TESTDIR"

					The status should be success
					The path testdir-index should be a file
					The path testdir-index should not be an empty file

					The contents of path testdir-index should include ">.file</a>"
					The contents of path testdir-index should include ">.dir/</a>"
					The contents of path testdir-index should include ">HEAD</a>"
					The contents of path testdir-index should include ">HEADER</a>"
					The contents of path testdir-index should include ">README</a>"
				End
			End
		End

		Describe "behaviour"
			It "should generate index files (not skip) for ignored directories"
				mkdir "$TESTDIR/dir"

				When run source "$SCRIPT" -i "dir" "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should not include ">dir/</a>"

				The path "$TESTDIR/dir/index.html" should be a file
				The path "$TESTDIR/dir/index.html" should not be an empty file
			End
		End

		Describe "warnings/errors"
			It "should show a warning for an empty ignore pattern"
				When run source "$SCRIPT" -i "" "$TESTDIR"

				The status should be failure
				The error should equal "$SCRIPT_NAME: warning: not applying empty ignore pattern"
				The path testdir-index should be a file
				The path testdir-index should not be an empty file
			End

			It "should show a warning for an ignore pattern with leading directories"
				touch "$TESTDIR/file"

				When run source "$SCRIPT" -i "path/file" "$TESTDIR"

				The status should be failure
				The error should equal "$SCRIPT_NAME: warning: removing leading directories of ignore pattern \"path/file\""
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should not include ">file</a>"
			End

			It "should show an error for a non-readable ignore patterns file"
				When run source "$SCRIPT" -I "$TESTDIR/nonexistent" "$TESTDIR"

				The status should be failure
				The error should equal "$SCRIPT_NAME: error: \"$TESTDIR/nonexistent\" is not a readable file"
				The path testdir-index should not exist
			End

			It "should show an error for an invalid ignore pattern option"
				When run source "$SCRIPT" -T invalid "$TESTDIR"

				The status should be failure
				The error should equal "$SCRIPT_NAME: error: \"invalid\" is not a valid ignore pattern option"
				The path testdir-index should not exist
			End
		End
	End

	Describe "skip patterns"
		Describe "source"
			setup_testdir() { for i in 1 2 3; do mkdir "$TESTDIR/dir$i"; done; }
			BeforeEach "setup_testdir"
			Path dir1-index="$TESTDIR/dir1/index.html"
			Path dir2-index="$TESTDIR/dir2/index.html"
			Path dir3-index="$TESTDIR/dir3/index.html"

			It "should skip directories that match patterns from the command line"
				When run source "$SCRIPT" -k "dir1" -k "d??2" -k "d*3" "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The path dir1-index should not exist
				The path dir2-index should not exist
				The path dir3-index should not exist
			End

			It "should skip directories that match patterns from a file"
				print0 "dir1" "d??2" "d*3" > "$TESTDIR/list"

				When run source "$SCRIPT" -K "$TESTDIR/list" "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The path dir1-index should not exist
				The path dir2-index should not exist
				The path dir3-index should not exist
			End

			It "should skip directories that match patterns from standard input"
				Data print0 "dir1" "d??2" "d*3"

				When run source "$SCRIPT" -K - "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The path dir1-index should not exist
				The path dir2-index should not exist
				The path dir3-index should not exist
			End
		End

		Describe "options"
			Describe "dot directories"
				setup_testdirs() { mkdir "$TESTDIR/.dir"; }
				BeforeEach "setup_testdirs"
				Path dot-dir-index="$TESTDIR/.dir/index.html"

				It "should skip dot directories by default"
					When run source "$SCRIPT" "$TESTDIR"

					The status should be success
					The path testdir-index should be a file
					The path testdir-index should not be an empty file

					The path dot-dir-index should not exist
				End

				It "should skip dot directories with -W skip-dot"
					When run source "$SCRIPT" -W skip-dot "$TESTDIR"

					The status should be success
					The path testdir-index should be a file
					The path testdir-index should not be an empty file

					The path dot-dir-index should not exist
				End

				It "should not skip dot directories with -W no-skip-dot"
					When run source "$SCRIPT" -W no-skip-dot "$TESTDIR"

					The status should be success
					The path testdir-index should be a file
					The path testdir-index should not be an empty file

					The path dot-dir-index should be a file
					The path dot-dir-index should not be an empty file
				End
			End

			Describe "skip ignore patterns"
				setup_testdir() { mkdir "$TESTDIR/dir"; }
				BeforeEach "setup_testdir"
				Path dir-index="$TESTDIR/dir/index.html"

				It "should not apply ignore patterns to skip directories by default"
					When run source "$SCRIPT" -i "dir" "$TESTDIR"

					The status should be success
					The path testdir-index should be a file
					The path testdir-index should not be an empty file

					The path dir-index should be a file
					The path dir-index should not be an empty file
				End

				It "should not apply ignore patterns to skip directories with -W no-skip-ignores"
					When run source "$SCRIPT" -i "dir" -W no-skip-ignores "$TESTDIR"

					The status should be success
					The path testdir-index should be a file
					The path testdir-index should not be an empty file

					The path dir-index should be a file
					The path dir-index should not be an empty file
				End

				It "should apply ignore patterns to skip directories with -W skip-ignores"
					When run source "$SCRIPT" -i "dir" -W skip-ignores "$TESTDIR"

					The status should be success
					The path testdir-index should be a file
					The path testdir-index should not be an empty file

					The path dir-index should not exist
				End
			End

			Describe "multiple options"
				setup_testdirs() { mkdir "$TESTDIR/.dir"; mkdir "$TESTDIR/dir"; }
				BeforeEach "setup_testdirs"
				Path dot-dir-index="$TESTDIR/.dir/index.html"
				Path dir-index="$TESTDIR/dir/index.html"

				It "should not skip dot directories and apply ignore patterns to skip directories with -W no-skip-dot,skip-ignores"
					When run source "$SCRIPT" -i "dir" -T no-ignore-dot -W no-skip-dot,skip-ignores "$TESTDIR"

					The status should be success
					The path testdir-index should be a file
					The path testdir-index should not be an empty file

					The path dot-dir-index should be a file
					The path dot-dir-index should not be an empty file

					The path dir-index should not exist
				End
			End
		End

		Describe "behaviour"
			setup_testdir() { mkdir "$TESTDIR/dir"; }
			BeforeEach "setup_testdir"
			Path dir-index="$TESTDIR/dir/index.html"

			It "should include skipped directories in parent directory index files (not ignore)"
				When run source "$SCRIPT" -k "dir" "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should include ">dir/</a>"

				The path dir-index should not exist
			End

			It "should skip descendents of matching directories"
				mkdir "$TESTDIR/dir/subdir"

				When run source "$SCRIPT" -k "dir" "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The path "$TESTDIR/dir/subdir/index.html" should not exist
			End

			It "should not skip root directories"
				mkdir "$TESTDIR/dir/dir"

				When run source "$SCRIPT" -k "dir" "$TESTDIR/dir"

				The status should be success
				The path dir-index should be a file
				The path dir-index should not be an empty file

				The path "$TESTDIR/dir/dir/index.html" should not exist
			End
		End

		Describe "warnings/errors"
			It "should show a warning for an empty skip pattern"
				When run source "$SCRIPT" -k "" "$TESTDIR"

				The status should be failure
				The error should equal "$SCRIPT_NAME: warning: not applying empty skip pattern"
				The path testdir-index should be a file
				The path testdir-index should not be an empty file
			End

			It "should show a warning for a skip pattern with leading directories"
				mkdir "$TESTDIR/dir"

				When run source "$SCRIPT" -k "path/dir" "$TESTDIR"

				The status should be failure
				The error should equal "$SCRIPT_NAME: warning: removing leading directories of skip pattern \"path/dir\""
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The path "$TESTDIR/dir/index.html" should not exist
			End

			It "should show an error for a non-readable skip patterns file"
				When run source "$SCRIPT" -K "$TESTDIR/nonexistent" "$TESTDIR"

				The status should be failure
				The error should equal "$SCRIPT_NAME: error: \"$TESTDIR/nonexistent\" is not a readable file"
				The path testdir-index should not exist
			End

			It "should show an error for an invalid skip pattern option"
				When run source "$SCRIPT" -W invalid "$TESTDIR"

				The status should be failure
				The error should equal "$SCRIPT_NAME: error: \"invalid\" is not a valid skip pattern option"
				The path testdir-index should not exist
			End
		End
	End

	Describe "whitespace characters"
		ht="$SHELLSPEC_HT"
		cr="$SHELLSPEC_CR"
		lf="$SHELLSPEC_LF"
		sp=" "

		Parameters
			"tab in middle"   "word${ht}word"
			"CR in middle"    "word${cr}word"
			"LF in middle"    "word${lf}word"
			"space in middle" "word${sp}word"
			"CRLF in middle"  "word${cr}${lf}word"
			"LFCR in middle"  "word${lf}${cr}word"
			"leading tab"     "${ht}word"
			"leading CR"      "${cr}word"
			"leading LF"      "${lf}word"
			"leading space"   "${sp}word"
			"leading CRLF"    "${cr}${lf}word"
			"leading LFCR"    "${lf}${cr}word"
			"trailing tab"    "word${ht}"
			"trailing CR"     "word${cr}"
			"trailing LF"     "word${lf}"
			"trailing space"  "word${sp}"
			"trailing CRLF"   "word${cr}${lf}"
			"trailing LFCR"   "word${lf}${cr}"
			"tab only"        "${ht}"
			"CR only"         "${cr}"
			"LF only"         "${lf}"
			"space only"      "${sp}"
			"CRLF only"       "${cr}${lf}"
			"LFCR only"       "${lf}${cr}"
		End

		Example "root directory name with $1 from the command line"
			mkdir "$TESTDIR/$2"

			When run source "$SCRIPT" "$TESTDIR/$2"

			The status should be success
			The path "$TESTDIR/$2/index.html" should be a file
			The path "$TESTDIR/$2/index.html" should not be an empty file
		End

		Example "root directory name with $1 from a file"
			mkdir "$TESTDIR/$2"
			print0 "$TESTDIR/$2" > "$TESTDIR/list"

			When run source "$SCRIPT" -g "$TESTDIR/list"

			The status should be success
			The path "$TESTDIR/$2/index.html" should be a file
			The path "$TESTDIR/$2/index.html" should not be an empty file
		End

		Example "root directory name with $1 from standard input"
			mkdir "$TESTDIR/$2"
			Data print0 "$TESTDIR/$2"

			When run source "$SCRIPT" -g -

			The status should be success
			The path "$TESTDIR/$2/index.html" should be a file
			The path "$TESTDIR/$2/index.html" should not be an empty file
		End

		Example "file name with $1"
			touch "$TESTDIR/$2"

			When run source "$SCRIPT" "$TESTDIR"

			The status should be success
			The path testdir-index should be a file
			The path testdir-index should not be an empty file

			The contents of path testdir-index should include ">$2</a>"
		End

		Example "subdirectory name with $1"
			mkdir "$TESTDIR/$2"

			When run source "$SCRIPT" "$TESTDIR"

			The status should be success
			The path testdir-index should be a file
			The path testdir-index should not be an empty file

			The contents of path testdir-index should include ">$2/</a>"

			The path "$TESTDIR/$2/index.html" should be a file
			The path "$TESTDIR/$2/index.html" should not be an empty file

			The contents of path "$TESTDIR/$2/index.html" should include ">Index of /$2</title>"
		End

		Example "ignore pattern with $1 from the command line"
			touch "$TESTDIR/$2"

			When run source "$SCRIPT" -i "$2" "$TESTDIR"

			The status should be success
			The path testdir-index should be a file
			The path testdir-index should not be an empty file

			The contents of path testdir-index should not include ">$2</a>"
		End

		Example "ignore pattern with $1 from a file"
			touch "$TESTDIR/$2"
			print0 "$2" > "$TESTDIR/list"

			When run source "$SCRIPT" -I "$TESTDIR/list" "$TESTDIR"

			The status should be success
			The path testdir-index should be a file
			The path testdir-index should not be an empty file

			The contents of path testdir-index should not include ">$2</a>"
		End

		Example "ignore pattern with $1 from standard input"
			touch "$TESTDIR/$2"
			Data print0 "$2"

			When run source "$SCRIPT" -I - "$TESTDIR"

			The status should be success
			The path testdir-index should be a file
			The path testdir-index should not be an empty file

			The contents of path testdir-index should not include ">$2</a>"
		End

		Example "skip pattern with $1 from the command line"
			mkdir "$TESTDIR/$2"

			When run source "$SCRIPT" -k "$2" "$TESTDIR"

			The status should be success
			The path testdir-index should be a file
			The path testdir-index should not be an empty file

			The path "$TESTDIR/$2/index.html" should not exist
		End

		Example "skip pattern with $1 from a file"
			mkdir "$TESTDIR/$2"
			print0 "$2" > "$TESTDIR/list"

			When run source "$SCRIPT" -K "$TESTDIR/list" "$TESTDIR"

			The status should be success
			The path testdir-index should be a file
			The path testdir-index should not be an empty file

			The path "$TESTDIR/$2/index.html" should not exist
		End

		Example "skip pattern with $1 from standard input"
			mkdir "$TESTDIR/$2"
			Data print0 "$2"

			When run source "$SCRIPT" -K - "$TESTDIR"

			The status should be success
			The path testdir-index should be a file
			The path testdir-index should not be an empty file

			The path "$TESTDIR/$2/index.html" should not exist
		End
	End
End
