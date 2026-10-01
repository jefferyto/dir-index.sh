#
# 60-output-html_spec.sh
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

% TESTDIR: "$SHELLSPEC_TMPBASE/dir-index-sh/output-html"
% FIXTURE: "$SHELLSPEC_HELPERDIR/fixture"

Describe "HTML output"
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
	Path testdir-index="$TESTDIR/index.html"

	Describe "page title"
		setup_testdir() { mkdir "$TESTDIR/dir"; }
		BeforeEach "setup_testdir"
		Path dir-index="$TESTDIR/dir/index.html"

		It "should use \"Index of ...\" as the page title by default"
			When run source "$SCRIPT" -O html "$TESTDIR"

			The status should be success
			The path testdir-index should be a file
			The path testdir-index should not be an empty file

			The contents of path testdir-index should include ">Index of /</title>"

			The path dir-index should be a file
			The path dir-index should not be an empty file

			The contents of path dir-index should include ">Index of /dir</title>"
		End

		It "should use an escaped custom page title with -t"
			When run source "$SCRIPT" -O html -t "foo %s & bar" "$TESTDIR"

			The status should be success
			The path testdir-index should be a file
			The path testdir-index should not be an empty file

			The contents of path testdir-index should include ">foo / &amp; bar</title>"

			The path dir-index should be a file
			The path dir-index should not be an empty file

			The contents of path dir-index should include ">foo /dir &amp; bar</title>"
		End

		It "should include the virtual path with -X"
			When run source "$SCRIPT" -O html -X foo/bar "$TESTDIR"

			The status should be success
			The path testdir-index should be a file
			The path testdir-index should not be an empty file

			The contents of path testdir-index should include ">Index of /foo/bar</title>"

			The path dir-index should be a file
			The path dir-index should not be an empty file

			The contents of path dir-index should include ">Index of /foo/bar/dir</title>"
		End
	End

	Describe "page text direction"
		It "should not set any page text direction by default"
			When run source "$SCRIPT" -O html "$TESTDIR"

			The status should be success
			The path testdir-index should be a file
			The path testdir-index should not be an empty file

			The contents of path testdir-index should not include " dir="
		End

		It "should use an escaped custom page text direction with -w"
			When run source "$SCRIPT" -O html -w "foo & bar" "$TESTDIR"

			The status should be success
			The path testdir-index should be a file
			The path testdir-index should not be an empty file

			The contents of path testdir-index should include "<html dir=\"foo &amp; bar\""
		End
	End

	Describe "page language"
		It "should use \"en\" as the page language by default"
			When run source "$SCRIPT" -O html "$TESTDIR"

			The status should be success
			The path testdir-index should be a file
			The path testdir-index should not be an empty file

			The contents of path testdir-index should include "<html lang=\"en\">"
		End

		It "should use an escaped custom page language with -l"
			When run source "$SCRIPT" -O html -l "foo & bar" "$TESTDIR"

			The status should be success
			The path testdir-index should be a file
			The path testdir-index should not be an empty file

			The contents of path testdir-index should include "<html lang=\"foo &amp; bar\">"
		End
	End

	Describe "page charset"
		It "should use \"utf-8\" as the page charset by default"
			When run source "$SCRIPT" -O html "$TESTDIR"

			The status should be success
			The path testdir-index should be a file
			The path testdir-index should not be an empty file

			The contents of path testdir-index should include "<meta charset=\"utf-8\">"
		End

		It "should use an escaped custom page charset with -A"
			When run source "$SCRIPT" -O html -A "foo & bar" "$TESTDIR"

			The status should be success
			The path testdir-index should be a file
			The path testdir-index should not be an empty file

			The contents of path testdir-index should include "<meta charset=\"foo &amp; bar\">"
		End
	End

	Describe "style"
		setup_testdir() {
			for i in data nodata dir; do mkdir "$TESTDIR/$i"; done
			mkdir "$TESTDIR/data/$PACKAGE_TARNAME"
			mkdir "$TESTDIR/data/$PACKAGE_TARNAME/styles"
			%printf 'foobar' > "$TESTDIR/data/$PACKAGE_TARNAME/styles/test-style.css"
		}
		BeforeEach "setup_testdir"
		Path dir-index="$TESTDIR/dir/index.html"

		It "should not include any style by default"
			When run source "$SCRIPT" -O html "$TESTDIR/dir"

			The status should be success
			The path dir-index should be a file
			The path dir-index should not be an empty file

			The contents of path dir-index should not include "</style></head>"
		End

		It "should include a built-in style from XDG_DATA_HOME with -y"
			export XDG_DATA_HOME="$TESTDIR/data"
			export XDG_DATA_DIRS="$TESTDIR/nodata"

			When run source "$SCRIPT" -O html -y test-style "$TESTDIR/dir"

			The status should be success
			The path dir-index should be a file
			The path dir-index should not be an empty file

			The contents of path dir-index should include "<style>foobar</style></head>"
		End

		It "should include a built-in style from XDG_DATA_DIRS (single entry) with -y"
			export XDG_DATA_HOME="$TESTDIR/nodata"
			export XDG_DATA_DIRS="$TESTDIR/data"

			When run source "$SCRIPT" -O html -y test-style "$TESTDIR/dir"

			The status should be success
			The path dir-index should be a file
			The path dir-index should not be an empty file

			The contents of path dir-index should include "<style>foobar</style></head>"
		End

		It "should include a built-in style from XDG_DATA_DIRS (multiple entries) with -y"
			export XDG_DATA_HOME="$TESTDIR/nodata"
			export XDG_DATA_DIRS="$TESTDIR/nodata::$TESTDIR/data"

			When run source "$SCRIPT" -O html -y test-style "$TESTDIR/dir"

			The status should be success
			The path dir-index should be a file
			The path dir-index should not be an empty file

			The contents of path dir-index should include "<style>foobar</style></head>"
		End

		It "should include a built-in style from script location with -y"
			export XDG_DATA_HOME="$TESTDIR/nodata"
			export XDG_DATA_DIRS="$TESTDIR/nodata"

			When run source "$SCRIPT" -O html -y classic "$TESTDIR/dir"

			The status should be success
			The path dir-index should be a file
			The path dir-index should not be an empty file

			The contents of path dir-index should include "</style></head>"
		End

		It "should not include any style with -y none"
			export XDG_DATA_HOME="$TESTDIR/data"
			export XDG_DATA_DIRS="$TESTDIR/data"
			cp "$TESTDIR/data/$PACKAGE_TARNAME/styles/test-style.css" \
				"$TESTDIR/data/$PACKAGE_TARNAME/styles/none.css"

			When run source "$SCRIPT" -O html -y none "$TESTDIR/dir"

			The status should be success
			The path dir-index should be a file
			The path dir-index should not be an empty file

			The contents of path dir-index should not include "</style></head>"
		End

		It "should show an error for an unknown style"
			export XDG_DATA_HOME="$TESTDIR/nodata"
			export XDG_DATA_DIRS="$TESTDIR/nodata"

			When run source "$SCRIPT" -O html -y unknown "$TESTDIR/dir"

			The status should be failure
			The error should equal "$SCRIPT_NAME: error: cannot find style \"unknown\""
			The path dir-index should not exist
		End
	End

	Describe "head/header/readme content"
		Describe "from command line"
			Parameters
				"head"   "-e" "</head>"
				"header" "-d" "</h1>"
				"readme" "-r" "</address>"
			End

			It "should use an unescaped custom $1 with $2"
				When run source "$SCRIPT" -O html "$2" "content&" "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should include "content&$3"
			End
		End

		Describe "from file"
			setup_testdir() {
				mkdir "$TESTDIR/dir1"
				mkdir "$TESTDIR/dir2"
				mkdir "$TESTDIR/dir2/dir"
				%printf 'content&' > "$TESTDIR/dir2/file"
			}
			BeforeEach "setup_testdir"
			Path dir1-index="$TESTDIR/dir1/index.html"
			Path dir2-index="$TESTDIR/dir2/index.html"
			Path dir2-dir-index="$TESTDIR/dir2/dir/index.html"

			Parameters
				"head"   "-E" "</head>"
				"header" "-D" "<ul class=\"breadcrumbs\">"
				"readme" "-R" "</body>"
			End

			It "should use unescaped $1 content from a file (base name) with $2"
				When run source "$SCRIPT" -O html "$2" file "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should not include "content&$3"
				The contents of path testdir-index should not include "content&amp;$3"

				The path dir1-index should be a file
				The path dir1-index should not be an empty file

				The contents of path dir1-index should not include "content&$3"
				The contents of path dir1-index should not include "content&amp;$3"

				The path dir2-index should be a file
				The path dir2-index should not be an empty file

				The contents of path dir2-index should include "content&$3"

				The path dir2-dir-index should be a file
				The path dir2-dir-index should not be an empty file

				The contents of path dir2-dir-index should not include "content&$3"
				The contents of path dir2-dir-index should not include "content&amp;$3"
			End

			It "should use unescaped $1 content from a file (path) with $2"
				When run source "$SCRIPT" -O html "$2" "$TESTDIR/dir2/file" "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should include "content&$3"

				The path dir1-index should be a file
				The path dir1-index should not be an empty file

				The contents of path dir1-index should include "content&$3"

				The path dir2-index should be a file
				The path dir2-index should not be an empty file

				The contents of path dir2-index should include "content&$3"

				The path dir2-dir-index should be a file
				The path dir2-dir-index should not be an empty file

				The contents of path dir2-dir-index should include "content&$3"
			End

			It "should use unescaped $1 content from standard input with $2"
				Data cat "$TESTDIR/dir2/file"

				When run source "$SCRIPT" -O html "$2" - "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should include "content&$3"

				The path dir1-index should be a file
				The path dir1-index should not be an empty file

				The contents of path dir1-index should include "content&$3"

				The path dir2-index should be a file
				The path dir2-index should not be an empty file

				The contents of path dir2-index should include "content&$3"

				The path dir2-dir-index should be a file
				The path dir2-dir-index should not be an empty file

				The contents of path dir2-dir-index should include "content&$3"
			End

			It "should show an error for non-readable $1 file (path)"
				When run source "$SCRIPT" -O html "$2" "$TESTDIR/nonexistent" "$TESTDIR"

				The status should be failure
				The error should equal "$SCRIPT_NAME: error: \"$TESTDIR/nonexistent\" is not a readable file"
				The path testdir-index should not exist
			End
		End
	End

	Describe "head content"
		It "should be able to add content multiple times with -e"
			When run source "$SCRIPT" -O html -e content -e "&" "$TESTDIR"

			The status should be success
			The path testdir-index should be a file
			The path testdir-index should not be an empty file

			The contents of path testdir-index should include "content&</head>"
		End
	End

	Describe "header content"
		setup_testdir() { mkdir "$TESTDIR/dir"; }
		BeforeEach "setup_testdir"
		Path dir-index="$TESTDIR/dir/index.html"

		It "should use \"Index of ...\" as the header by default"
			When run source "$SCRIPT" -O html "$TESTDIR"

			The status should be success
			The path testdir-index should be a file
			The path testdir-index should not be an empty file

			The contents of path testdir-index should include ">Index of /</h1>"

			The path dir-index should be a file
			The path dir-index should not be an empty file

			The contents of path dir-index should include ">Index of /dir</h1>"
		End

		It "should use an unescaped custom header (%s replaced with the path) with -d"
			When run source "$SCRIPT" -O html -d "foo %s & bar" "$TESTDIR"

			The status should be success
			The path testdir-index should be a file
			The path testdir-index should not be an empty file

			The contents of path testdir-index should include ">foo / & bar</h1>"

			The path dir-index should be a file
			The path dir-index should not be an empty file

			The contents of path dir-index should include ">foo /dir & bar</h1>"
		End

		It "should include the virtual path with -X"
			When run source "$SCRIPT" -O html -X foo/bar "$TESTDIR"

			The status should be success
			The path testdir-index should be a file
			The path testdir-index should not be an empty file

			The contents of path testdir-index should include ">Index of /foo/bar</h1>"

			The path dir-index should be a file
			The path dir-index should not be an empty file

			The contents of path dir-index should include ">Index of /foo/bar/dir</h1>"
		End
	End

	Describe "breadcrumbs"
		Describe "items"
			setup_testdir() { mkdir "$TESTDIR/dir"; mkdir "$TESTDIR/dir/subdir"; }
			BeforeEach "setup_testdir"
			Path dir-index="$TESTDIR/dir/index.html"
			Path subdir-index="$TESTDIR/dir/subdir/index.html"

			It "should contain items/links for each segment of the current path"
				When run source "$SCRIPT" -O html "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should include "<ul class=\"breadcrumbs\"><li><span>Home</span></li></ul>"

				The path dir-index should be a file
				The path dir-index should not be an empty file

				The contents of path dir-index should include "<ul class=\"breadcrumbs\"><li><a href=\"/\">Home</a></li><li><span>dir</span></li></ul>"

				The path subdir-index should be a file
				The path subdir-index should not be an empty file

				The contents of path subdir-index should include "<ul class=\"breadcrumbs\"><li><a href=\"/\">Home</a></li><li><a href=\"/dir/\">dir</a></li><li><span>subdir</span></li></ul>"
			End

			It "should include the virtual path with -X"
				When run source "$SCRIPT" -O html -X foo/bar "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should include "<ul class=\"breadcrumbs\"><li><a href=\"/\">Home</a></li><li><a href=\"/foo/\">foo</a></li><li><span>bar</span></li></ul>"

				The path dir-index should be a file
				The path dir-index should not be an empty file

				The contents of path dir-index should include "<ul class=\"breadcrumbs\"><li><a href=\"/\">Home</a></li><li><a href=\"/foo/\">foo</a></li><li><a href=\"/foo/bar/\">bar</a></li><li><span>dir</span></li></ul>"

				The path subdir-index should be a file
				The path subdir-index should not be an empty file

				The contents of path subdir-index should include "<ul class=\"breadcrumbs\"><li><a href=\"/\">Home</a></li><li><a href=\"/foo/\">foo</a></li><li><a href=\"/foo/bar/\">bar</a></li><li><a href=\"/foo/bar/dir/\">dir</a></li><li><span>subdir</span></li></ul>"
			End
		End

		Describe "root link"
			It "should use \"Home\" as the breadcrumbs root link text by default"
				When run source "$SCRIPT" -O html "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should include "<ul class=\"breadcrumbs\"><li><span>Home</span></li></ul>"
			End

			It "should use an unescaped custom breadcrumbs root link text with -x"
				When run source "$SCRIPT" -O html -x "foo & bar" "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should include "<ul class=\"breadcrumbs\"><li><span>foo & bar</span></li></ul>"
			End
		End
	End

	Describe "options"
		Describe "index format"
			It "should generate the index as a table by default"
				When run source "$SCRIPT" -O html "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should include "<table class=\"index"
				The contents of path testdir-index should not include "<ul class=\"index"
			End

			It "should generate the index as a table with -H table"
				When run source "$SCRIPT" -O html -H table "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should include "<table class=\"index"
				The contents of path testdir-index should not include "<ul class=\"index"
			End

			It "should generate the index as a list with -H list"
				When run source "$SCRIPT" -O html -H list "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should include "<ul class=\"index"
				The contents of path testdir-index should not include "<table class=\"index"
			End
		End

		Describe "horizontal rule"
			It "should have horizontal rule lines by default"
				When run source "$SCRIPT" -O html "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should include "<hr>"
			End

			It "should have horizontal rule lines with -H rules"
				When run source "$SCRIPT" -O html -H rules "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should include "<hr>"
			End

			It "should omit horizontal rule lines with -H no-rules"
				When run source "$SCRIPT" -O html -H no-rules "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should not include "<hr>"
			End
		End

		Describe "preamble"
			setup_testdir() {
				mkdir "$TESTDIR/dir1"
				mkdir "$TESTDIR/dir2"
				mkdir "$TESTDIR/dir2/dir"
				%printf 'content&' > "$TESTDIR/dir2/file"
			}
			BeforeEach "setup_testdir"
			Path dir1-index="$TESTDIR/dir1/index.html"
			Path dir2-index="$TESTDIR/dir2/index.html"
			Path dir2-dir-index="$TESTDIR/dir2/dir/index.html"

			It "should include opening and closing HTML by default"
				When run source "$SCRIPT" -O html "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should start with "<!DOCTYPE html>"
				The contents of path testdir-index should include "</html>"

				The path dir1-index should be a file
				The path dir1-index should not be an empty file

				The contents of path dir1-index should start with "<!DOCTYPE html>"
				The contents of path dir1-index should include "</html>"

				The path dir2-index should be a file
				The path dir2-index should not be an empty file

				The contents of path dir2-index should start with "<!DOCTYPE html>"
				The contents of path dir2-index should include "</html>"

				The path dir2-dir-index should be a file
				The path dir2-dir-index should not be an empty file

				The contents of path dir2-dir-index should start with "<!DOCTYPE html>"
				The contents of path dir2-dir-index should include "</html>"
			End

			It "should include opening and closing HTML with -H preamble"
				When run source "$SCRIPT" -O html -D "$TESTDIR/dir2/file" -R "$TESTDIR/dir2/file" -H preamble "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should start with "<!DOCTYPE html>"
				The contents of path testdir-index should include "</html>"

				The path dir1-index should be a file
				The path dir1-index should not be an empty file

				The contents of path dir1-index should start with "<!DOCTYPE html>"
				The contents of path dir1-index should include "</html>"

				The path dir2-index should be a file
				The path dir2-index should not be an empty file

				The contents of path dir2-index should start with "<!DOCTYPE html>"
				The contents of path dir2-index should include "</html>"

				The path dir2-dir-index should be a file
				The path dir2-dir-index should not be an empty file

				The contents of path dir2-dir-index should start with "<!DOCTYPE html>"
				The contents of path dir2-dir-index should include "</html>"
			End

			It "should include opening and closing HTML with -H no-preamble and without -D or -R"
				When run source "$SCRIPT" -O html -H no-preamble "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should start with "<!DOCTYPE html>"
				The contents of path testdir-index should include "</html>"

				The path dir1-index should be a file
				The path dir1-index should not be an empty file

				The contents of path dir1-index should start with "<!DOCTYPE html>"
				The contents of path dir1-index should include "</html>"

				The path dir2-index should be a file
				The path dir2-index should not be an empty file

				The contents of path dir2-index should start with "<!DOCTYPE html>"
				The contents of path dir2-index should include "</html>"

				The path dir2-dir-index should be a file
				The path dir2-dir-index should not be an empty file

				The contents of path dir2-dir-index should start with "<!DOCTYPE html>"
				The contents of path dir2-dir-index should include "</html>"
			End

			It "should omit opening HTML with -D (base name) and -H no-preamble"
				When run source "$SCRIPT" -O html -D file -H no-preamble "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should start with "<!DOCTYPE html>"

				The path dir1-index should be a file
				The path dir1-index should not be an empty file

				The contents of path dir1-index should start with "<!DOCTYPE html>"

				The path dir2-index should be a file
				The path dir2-index should not be an empty file

				The contents of path dir2-index should start with "content&<ul class=\"breadcrumbs\">"

				The path dir2-dir-index should be a file
				The path dir2-dir-index should not be an empty file

				The contents of path dir2-dir-index should start with "<!DOCTYPE html>"
			End

			It "should omit opening HTML with -D (path) and -H no-preamble"
				When run source "$SCRIPT" -O html -D "$TESTDIR/dir2/file" -H no-preamble "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should start with "content&<ul class=\"breadcrumbs\">"

				The path dir1-index should be a file
				The path dir1-index should not be an empty file

				The contents of path dir1-index should start with "content&<ul class=\"breadcrumbs\">"

				The path dir2-index should be a file
				The path dir2-index should not be an empty file

				The contents of path dir2-index should start with "content&<ul class=\"breadcrumbs\">"

				The path dir2-dir-index should be a file
				The path dir2-dir-index should not be an empty file

				The contents of path dir2-dir-index should start with "content&<ul class=\"breadcrumbs\">"
			End

			It "should omit opening HTML with -D (standard input) and -H no-preamble"
				Data cat "$TESTDIR/dir2/file"

				When run source "$SCRIPT" -O html -D - -H no-preamble "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should start with "content&<ul class=\"breadcrumbs\">"

				The path dir1-index should be a file
				The path dir1-index should not be an empty file

				The contents of path dir1-index should start with "content&<ul class=\"breadcrumbs\">"

				The path dir2-index should be a file
				The path dir2-index should not be an empty file

				The contents of path dir2-index should start with "content&<ul class=\"breadcrumbs\">"

				The path dir2-dir-index should be a file
				The path dir2-dir-index should not be an empty file

				The contents of path dir2-dir-index should start with "content&<ul class=\"breadcrumbs\">"
			End

			It "should omit closing HTML with -R (base name) and -H no-preamble"
				When run source "$SCRIPT" -O html -R file -H no-preamble "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should include "</html>"

				The path dir1-index should be a file
				The path dir1-index should not be an empty file

				The contents of path dir1-index should include "</html>"

				The path dir2-index should be a file
				The path dir2-index should not be an empty file

				The contents of path dir2-index should include "</table>content&"
				The contents of path dir2-index should not include "</html>"

				The path dir2-dir-index should be a file
				The path dir2-dir-index should not be an empty file

				The contents of path dir2-dir-index should include "</html>"
			End

			It "should omit closing HTML with -R (path) and -H no-preamble"
				When run source "$SCRIPT" -O html -R "$TESTDIR/dir2/file" -H no-preamble "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should include "</table>content&"
				The contents of path testdir-index should not include "</html>"

				The path dir1-index should be a file
				The path dir1-index should not be an empty file

				The contents of path dir1-index should include "</table>content&"
				The contents of path dir1-index should not include "</html>"

				The path dir2-index should be a file
				The path dir2-index should not be an empty file

				The contents of path dir2-index should include "</table>content&"
				The contents of path dir2-index should not include "</html>"

				The path dir2-dir-index should be a file
				The path dir2-dir-index should not be an empty file

				The contents of path dir2-dir-index should include "</table>content&"
				The contents of path dir2-dir-index should not include "</html>"
			End

			It "should omit closing HTML with -R (standard input) and -H no-preamble"
				Data cat "$TESTDIR/dir2/file"

				When run source "$SCRIPT" -O html -R - -H no-preamble "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should include "</table>content&"
				The contents of path testdir-index should not include "</html>"

				The path dir1-index should be a file
				The path dir1-index should not be an empty file

				The contents of path dir1-index should include "</table>content&"
				The contents of path dir1-index should not include "</html>"

				The path dir2-index should be a file
				The path dir2-index should not be an empty file

				The contents of path dir2-index should include "</table>content&"
				The contents of path dir2-index should not include "</html>"

				The path dir2-dir-index should be a file
				The path dir2-dir-index should not be an empty file

				The contents of path dir2-dir-index should include "</table>content&"
				The contents of path dir2-dir-index should not include "</html>"
			End
		End

		Describe "errors"
			It "should show an error for an invalid option"
				When run source "$SCRIPT" -O html -H invalid "$TESTDIR"

				The status should be failure
				The error should equal "$SCRIPT_NAME: error: \"invalid\" is not a valid HTML output option"
				The path testdir-index should not exist
			End
		End
	End

	Describe "index columns"
		It "should have name, last modified and size column order by default"
			When run source "$SCRIPT" -O html "$TESTDIR"

			The status should be success
			The path testdir-index should be a file
			The path testdir-index should not be an empty file

			The contents of path testdir-index should satisfy has_order Name "Last modified" Size
		End

		It "should reorder index columns with -C"
			When run source "$SCRIPT" -O html -C size,name,modified "$TESTDIR"

			The status should be success
			The path testdir-index should be a file
			The path testdir-index should not be an empty file

			The contents of path testdir-index should satisfy has_order Size Name "Last modified"
		End

		It "should omit index columns not included with -C"
			When run source "$SCRIPT" -O html -C name "$TESTDIR"

			The status should be success
			The path testdir-index should be a file
			The path testdir-index should not be an empty file

			The contents of path testdir-index should include ">Name</th>"
			The contents of path testdir-index should not include ">Last modified</th>"
			The contents of path testdir-index should not include ">Size</th>"
		End

		It "should show an error for an invalid column"
			When run source "$SCRIPT" -O html -C invalid "$TESTDIR"

			The status should be failure
			The error should equal "$SCRIPT_NAME: error: \"invalid\" is not a valid column"
			The path testdir-index should not exist
		End

		It "should show an error when name column is not included"
			When run source "$SCRIPT" -O html -C modified,size "$TESTDIR"

			The status should be failure
			The error should equal "$SCRIPT_NAME: error: name column must be included"
			The path testdir-index should not exist
		End
	End

	Describe "index column headings"
		Parameters
			"Name"          "-N"
			"Last modified" "-M"
			"Size"          "-Z"
		End

		It "should use \"$1\" as column heading by default"
			When run source "$SCRIPT" -O html "$TESTDIR"

			The status should be success
			The path testdir-index should be a file
			The path testdir-index should not be an empty file

			The contents of path testdir-index should include ">$1</th>"
		End

		It "should use an unescaped custom $1 column heading with $2"
			When run source "$SCRIPT" -O html "$2" "foo & bar" "$TESTDIR"

			The status should be success
			The path testdir-index should be a file
			The path testdir-index should not be an empty file

			The contents of path testdir-index should include ">foo & bar</th>"
			The contents of path testdir-index should not include ">$1</th>"
		End
	End

	Describe "index entries"
		Describe "no entries"
			It "should not set any data-type attribute"
				When run source "$SCRIPT" -O html "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should not include " data-type="
			End

			It "should not set any data-mime-type attribute"
				When run source "$SCRIPT" -O html "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should not include " data-mime-type="
			End

			It "should not set any data-file-name attribute"
				When run source "$SCRIPT" -O html "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should not include " data-file-name="
			End
		End

		Describe "parent entry"
			setup_testdir() { mkdir "$TESTDIR/dir"; mkdir "$TESTDIR/dir/subdir"; }
			BeforeEach "setup_testdir"
			Path subdir-index="$TESTDIR/dir/subdir/index.html"

			It "should set data-type=\"back\""
				When run source "$SCRIPT" -O html "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The path subdir-index should be a file
				The path subdir-index should not be an empty file

				The contents of path subdir-index should include " data-type=\"back\""
			End

			It "should not set any data-mime-type attribute"
				When run source "$SCRIPT" -O html "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The path subdir-index should be a file
				The path subdir-index should not be an empty file

				The contents of path subdir-index should not include " data-mime-type="
			End

			It "should not set any data-file-name attribute"
				When run source "$SCRIPT" -O html "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The path subdir-index should be a file
				The path subdir-index should not be an empty file

				The contents of path subdir-index should not include " data-file-name="
			End

			It "should link to the parent directory with leading and trailing slashes in link URL"
				When run source "$SCRIPT" -O html "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The path subdir-index should be a file
				The path subdir-index should not be an empty file

				The contents of path subdir-index should include "<td class=\"index__col--name\"><a href=\"/dir/\">"
			End

			It "should use \"Parent Directory\" as link text by default"
				When run source "$SCRIPT" -O html "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The path subdir-index should be a file
				The path subdir-index should not be an empty file

				The contents of path subdir-index should include ">Parent Directory</a></td>"
			End

			It "should use an escaped custom link text with -P"
				When run source "$SCRIPT" -O html -P "foo & bar" "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The path subdir-index should be a file
				The path subdir-index should not be an empty file

				The contents of path subdir-index should include ">foo &amp; bar</a></td>"
			End

			It "should have no value in the last modified column"
				When run source "$SCRIPT" -O html "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The path subdir-index should be a file
				The path subdir-index should not be an empty file

				The contents of path subdir-index should include "<td class=\"index__col--last-modified\"></td>"
			End

			It "should have \"-\" in the size column"
				When run source "$SCRIPT" -O html "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The path subdir-index should be a file
				The path subdir-index should not be an empty file

				The contents of path subdir-index should include "<td class=\"index__col--size\">-</td>"
			End
		End

		Describe "files"
			setup_testdir() {
				cp "$FIXTURE/tar.gif" "$TESTDIR/file.txt"
				touch -m -d "2099-07-08T12:34:56" "$TESTDIR/file.txt"
			}
			BeforeEach "setup_testdir"

			It "should set data-type=\"file\""
				When run source "$SCRIPT" -O html "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should include " data-type=\"file\""
			End

			It "should set data-mime-type attribute"
				When run source "$SCRIPT" -O html "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should include " data-mime-type=\"image/gif\""
			End

			It "should not set data-mime-type attribute if 'file' does not return a mime type"
				file() { :; }

				When run source "$SCRIPT" -O html "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should not include " data-mime-type="
			End

			It "should set data-file-name attribute"
				When run source "$SCRIPT" -O html "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should include " data-file-name=\"file.txt\""
			End

			It "should link to file"
				When run source "$SCRIPT" -O html "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should include "<a href=\"file.txt\">"
			End

			It "should use file name as link text"
				When run source "$SCRIPT" -O html "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should include ">file.txt</a></td>"
			End

			It "should have the file last modified date in the last modified column"
				When run source "$SCRIPT" -O html "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should include "<td class=\"index__col--last-modified\">2099-07-08 12:34</td>"
			End

			It "should have the file size in the size column"
				When run source "$SCRIPT" -O html "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should include "<td class=\"index__col--size\">243</td>"
			End
		End

		Describe "directories"
			setup_testdir() {
				mkdir "$TESTDIR/dir"
				touch -m -d "2099-07-08T12:34:56" "$TESTDIR/dir"
			}
			BeforeEach "setup_testdir"

			It "should set data-type=\"folder\""
				When run source "$SCRIPT" -O html "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should include " data-type=\"folder\""
			End

			It "should not set any data-mime-type attribute"
				When run source "$SCRIPT" -O html "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should not include " data-mime-type="
			End

			It "should set data-file-name attribute"
				When run source "$SCRIPT" -O html "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should include " data-file-name=\"dir\""
			End

			It "should link to directory with trailing slash in link URL"
				When run source "$SCRIPT" -O html "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should include "<td class=\"index__col--name\"><a href=\"dir/\">"
			End

			It "should use directory name with trailing slash as link text"
				When run source "$SCRIPT" -O html "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should include ">dir/</a></td>"
			End

			It "should have the directory last modified date in the last modified column"
				When run source "$SCRIPT" -O html "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should include "<td class=\"index__col--last-modified\">2099-07-08 12:34</td>"
			End

			It "should have \"-\" in the size column"
				When run source "$SCRIPT" -O html "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should include "<td class=\"index__col--size\">-</td>"
			End
		End
	End

	Describe "file last modified date"
		It "should use an unescaped last modified format with -m"
			lf="$SHELLSPEC_LF"
			touch -m -d "2099-07-08T12:34:56" "$TESTDIR/file"

			When run source "$SCRIPT" -O html -m "${lf}%M & %H < %d > %m ' %Y${lf}" "$TESTDIR"

			The status should be success
			The path testdir-index should be a file
			The path testdir-index should not be an empty file

			The contents of path testdir-index should include "<td class=\"index__col--last-modified\">${lf}34 & 12 < 08 > 07 ' 2099${lf}</td>"
		End

		It "should use have the last modified date in UTC with -u"
			touch -m -d "2099-07-08T12:34:56Z" "$TESTDIR/file"

			When run source "$SCRIPT" -O html -u "$TESTDIR"

			The status should be success
			The path testdir-index should be a file
			The path testdir-index should not be an empty file

			The contents of path testdir-index should include "<td class=\"index__col--last-modified\">2099-07-08 12:34</td>"
		End
	End

	Describe "file size"
		setup_testdir() { cp "$FIXTURE/compressed.png" "$TESTDIR"; }
		BeforeEach "setup_testdir"

		It "should use iec units by default"
			When run source "$SCRIPT" -O html "$TESTDIR"

			The status should be success
			The path testdir-index should be a file
			The path testdir-index should not be an empty file

			The contents of path testdir-index should include "<td class=\"index__col--size\">1.1K</td>"
		End

		It "should output exact sizes with -z none"
			When run source "$SCRIPT" -O html -z none "$TESTDIR"

			The status should be success
			The path testdir-index should be a file
			The path testdir-index should not be an empty file

			The contents of path testdir-index should include "<td class=\"index__col--size\">1108</td>"
		End

		It "should use si units with -z si"
			When run source "$SCRIPT" -O html -z si "$TESTDIR"

			The status should be success
			The path testdir-index should be a file
			The path testdir-index should not be an empty file

			The contents of path testdir-index should include "<td class=\"index__col--size\">1.2k</td>"
		End

		It "should use iec units with -z iec"
			When run source "$SCRIPT" -O html -z iec "$TESTDIR"

			The status should be success
			The path testdir-index should be a file
			The path testdir-index should not be an empty file

			The contents of path testdir-index should include "<td class=\"index__col--size\">1.1K</td>"
		End

		It "should use iec-i units -z iec-i"
			When run source "$SCRIPT" -O html -z iec-i "$TESTDIR"

			The status should be success
			The path testdir-index should be a file
			The path testdir-index should not be an empty file

			The contents of path testdir-index should include "<td class=\"index__col--size\">1.1Ki</td>"
		End

		It "should show an error for an invalid unit"
			When run source "$SCRIPT" -O html -z invalid "$TESTDIR"

			The status should be failure
			The error should equal "$SCRIPT_NAME: error: \"invalid\" is not a valid file size unit"
			The path testdir-index should not exist
		End
	End

	Describe "URL encoding"
		sp=" "
		ht="$SHELLSPEC_HT"
		cr="$SHELLSPEC_CR"
		lf="$SHELLSPEC_LF"

		Parameters
			"horizontal tab"  "$ht" "%09"
			"line feed"       "$lf" "%0A"
			"carriage return" "$cr" "%0D"
			"space"           "$sp" "%20"
			"double quotes"   '"'   "%22"
			"ampersand"       "&"   "%26"
			"single quote"    "'"   "%27"
			"less than"       "<"   "%3C"
			"greater than"    ">"   "%3E"
		End

		It "should encode $1 in breadcrumbs"
			mkdir "$TESTDIR/$2"
			mkdir "$TESTDIR/$2/dir"

			When run source "$SCRIPT" -O html "$TESTDIR"

			The status should be success
			The path testdir-index should be a file
			The path testdir-index should not be an empty file

			The path "$TESTDIR/$2/dir/index.html" should be a file
			The path "$TESTDIR/$2/dir/index.html" should not be an empty file

			The contents of path "$TESTDIR/$2/dir/index.html" should include "<a href=\"/$3/\">"
		End

		It "should encode $1 in index table"
			touch "$TESTDIR/$2"

			When run source "$SCRIPT" -O html "$TESTDIR"

			The status should be success
			The path testdir-index should be a file
			The path testdir-index should not be an empty file

			The contents of path testdir-index should include "<a href=\"$3\">"
		End

		It "should encode $1 in index list"
			touch "$TESTDIR/$2"

			When run source "$SCRIPT" -O html -H list "$TESTDIR"

			The status should be success
			The path testdir-index should be a file
			The path testdir-index should not be an empty file

			The contents of path testdir-index should include "<a href=\"$3\">"
		End
	End

	Describe "HTML escaping"
		Parameters
			"double quotes" '"' "&quot;"
			"ampersand"     "&" "&amp;"
			"single quote"  "'" "&apos;"
			"less than"     "<" "&lt;"
			"greater than"  ">" "&gt;"
		End

		It "should escape $1 in breadcrumbs"
			mkdir "$TESTDIR/$2"
			mkdir "$TESTDIR/$2/dir"

			When run source "$SCRIPT" -O html "$TESTDIR"

			The status should be success
			The path testdir-index should be a file
			The path testdir-index should not be an empty file

			The path "$TESTDIR/$2/dir/index.html" should be a file
			The path "$TESTDIR/$2/dir/index.html" should not be an empty file

			The contents of path "$TESTDIR/$2/dir/index.html" should include ">$3</a>"
		End

		It "should escape $1 in index table"
			mkdir "$TESTDIR/$2"

			When run source "$SCRIPT" -O html "$TESTDIR"

			The status should be success
			The path testdir-index should be a file
			The path testdir-index should not be an empty file

			The contents of path testdir-index should include "data-file-name=\"$3\""
			The contents of path testdir-index should include ">$3/</a>"

			The path "$TESTDIR/$2/index.html" should be a file
			The path "$TESTDIR/$2/index.html" should not be an empty file

			The contents of path "$TESTDIR/$2/index.html" should include ">Index of /$3</title>"
			The contents of path "$TESTDIR/$2/index.html" should include ">Index of /$3</h1>"
		End

		It "should escape $1 in index list"
			mkdir "$TESTDIR/$2"

			When run source "$SCRIPT" -O html -H list "$TESTDIR"

			The status should be success
			The path testdir-index should be a file
			The path testdir-index should not be an empty file

			The contents of path testdir-index should include "data-file-name=\"$3\""
			The contents of path testdir-index should include ">$3/</a>"

			The path "$TESTDIR/$2/index.html" should be a file
			The path "$TESTDIR/$2/index.html" should not be an empty file

			The contents of path "$TESTDIR/$2/index.html" should include ">Index of /$3</title>"
			The contents of path "$TESTDIR/$2/index.html" should include ">Index of /$3</h1>"
		End
	End
End
