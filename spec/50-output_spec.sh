#
# 50-output_spec.sh
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

% TESTDIR: "$SHELLSPEC_TMPBASE/dir-index-sh/output"
% FIXTURE: "$SHELLSPEC_HELPERDIR/fixture"

Describe "Output"
	BeforeEach "setup_testdir"
	AfterEach "teardown_testdir"
	Path testdir-index="$TESTDIR/index.html"
	Path xml-index="$TESTDIR/index.xml"
	Path json-index="$TESTDIR/index.json"

	Describe "name"
		Describe "default by format"
			Parameters:value "" html xml json

			It "should generate index.${1:-html}${1:+ with -O $1}"
				When run source "$SCRIPT" ${1:+-O "$1"} "$TESTDIR"

				The status should be success
				The path "$TESTDIR/index.${1:-html}" should be a file
				The path "$TESTDIR/index.${1:-html}" should not be an empty file
			End
		End

		Describe "custom name"
			It "should use the specified file name with -o"
				When run source "$SCRIPT" -o foobar "$TESTDIR"

				The status should be success
				The path "$TESTDIR/foobar" should be a file
				The path "$TESTDIR/foobar" should not be an empty file
			End
		End
	End

	Describe "format"
		Describe "valid formats"
			Parameters
				""    "<!DOCTYPE html>"  "</html>"
				html  "<!DOCTYPE html>"  "</html>"
				xml   "<?xml"            "</list>"
				json  "[]"               "[]"
			End

			It "should generate a ${1:-html} index file${1:+ with -O $1}"
				When run source "$SCRIPT" ${1:+-O "$1"} "$TESTDIR"

				The status should be success
				The path "$TESTDIR/index.${1:-html}" should be a file
				The path "$TESTDIR/index.${1:-html}" should not be an empty file

				The contents of path "$TESTDIR/index.${1:-html}" should start with "$2"
				The contents of path "$TESTDIR/index.${1:-html}" should include "$3"
			End
		End

		Describe "whitespace around keyword"
			It "should strip leading whitespace"
				ht="$SHELLSPEC_HT"
				lf="$SHELLSPEC_LF"
				vt="$SHELLSPEC_VT"
				ff="$SHELLSPEC_FF"
				cr="$SHELLSPEC_CR"
				sp=" "

				When run source "$SCRIPT" -O "${ff}${cr}${vt}xml" "$TESTDIR"

				The status should be success
				The path xml-index should be a file
				The path xml-index should not be an empty file
			End

			It "should strip trailing whitespace"
				ht="$SHELLSPEC_HT"
				lf="$SHELLSPEC_LF"
				vt="$SHELLSPEC_VT"
				ff="$SHELLSPEC_FF"
				cr="$SHELLSPEC_CR"
				sp=" "

				When run source "$SCRIPT" -O "json${sp}${lf}${ht}" "$TESTDIR"

				The status should be success
				The path json-index should be a file
				The path json-index should not be an empty file
			End
		End

		Describe "invalid format"
			It "should show an error"
				When run source "$SCRIPT" -O invalid "$TESTDIR"

				The status should be failure
				The error should equal "$SCRIPT_NAME: error: \"invalid\" is not a valid output format"
				The path testdir-index should not exist
			End
		End
	End

	Describe "sort"
		Describe "primary by property"
			setup_example() {
				%printf '' > "$TESTDIR/c"
				mkdir "$TESTDIR/d"
				%printf '##' > "$TESTDIR/a"
				mkdir "$TESTDIR/b"
				%printf '#' > "$TESTDIR/e"
				mkdir "$TESTDIR/f"
				s=1
				for i in c d a b e f; do
					touch -m -d "2099-07-08T12:34:5${s}Z" "$TESTDIR/$i"
					s="$((s + 1))"
				done
			}
			BeforeEach "setup_example"

			Parameters
				"name, ascending, folders mixed"            ""        ""                     a   b/  c   d/  e   f/
				"name, ascending, folders mixed"            ""        asc                    a   b/  c   d/  e   f/
				"name, descending, folders mixed"           ""        desc                   f/  e   d/  c   b/  a
				"name, ascending, folders mixed"            ""        no-folders-first       a   b/  c   d/  e   f/
				"name, ascending, folders first"            ""        folders-first          b/  d/  f/  a   c   e
				"name, ascending, folders mixed"            ""        asc,no-folders-first   a   b/  c   d/  e   f/
				"name, descending, folders mixed"           ""        desc,no-folders-first  f/  e   d/  c   b/  a
				"name, ascending, folders first"            ""        asc,folders-first      b/  d/  f/  a   c   e
				"name, descending, folders first"           ""        desc,folders-first     f/  d/  b/  e   c   a
				"name, ascending, folders mixed"            name      ""                     a   b/  c   d/  e   f/
				"name, ascending, folders mixed"            name      asc                    a   b/  c   d/  e   f/
				"name, descending, folders mixed"           name      desc                   f/  e   d/  c   b/  a
				"name, ascending, folders mixed"            name      no-folders-first       a   b/  c   d/  e   f/
				"name, ascending, folders first"            name      folders-first          b/  d/  f/  a   c   e
				"name, ascending, folders mixed"            name      asc,no-folders-first   a   b/  c   d/  e   f/
				"name, descending, folders mixed"           name      desc,no-folders-first  f/  e   d/  c   b/  a
				"name, ascending, folders first"            name      asc,folders-first      b/  d/  f/  a   c   e
				"name, descending, folders first"           name      desc,folders-first     f/  d/  b/  e   c   a
				"last modified, ascending, folders mixed"   modified  ""                     c   d/  a   b/  e   f/
				"last modified, ascending, folders mixed"   modified  asc                    c   d/  a   b/  e   f/
				"last modified, descending, folders mixed"  modified  desc                   f/  e   b/  a   d/  c
				"last modified, ascending, folders mixed"   modified  no-folders-first       c   d/  a   b/  e   f/
				"last modified, ascending, folders first"   modified  folders-first          d/  b/  f/  c   a   e
				"last modified, ascending, folders mixed"   modified  asc,no-folders-first   c   d/  a   b/  e   f/
				"last modified, descending, folders mixed"  modified  desc,no-folders-first  f/  e   b/  a   d/  c
				"last modified, ascending, folders first"   modified  asc,folders-first      d/  b/  f/  c   a   e
				"last modified, descending, folders first"  modified  desc,folders-first     f/  b/  d/  e   a   c
				"size, ascending, folders mixed"            size      ""                     b/  d/  f/  c   e   a
				"size, ascending, folders mixed"            size      asc                    b/  d/  f/  c   e   a
				"size, descending, folders mixed"           size      desc                   a   e   c   f/  d/  b/
				"size, ascending, folders mixed"            size      no-folders-first       b/  d/  f/  c   e   a
				"size, ascending, folders first"            size      folders-first          b/  d/  f/  c   e   a
				"size, ascending, folders mixed"            size      asc,no-folders-first   b/  d/  f/  c   e   a
				"size, descending, folders mixed"           size      desc,no-folders-first  a   e   c   f/  d/  b/
				"size, ascending, folders first"            size      asc,folders-first      b/  d/  f/  c   e   a
				"size, descending, folders first"           size      desc,folders-first     f/  d/  b/  a   e   c
			End

			It "should sort entries by $1${2:+ with -s $2}${3:+ -S $3} (html)"
				When run source "$SCRIPT" -O html ${2:+-s "$2"} ${3:+-S "$3"} "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should satisfy has_order html "$4" "$5" "$6" "$7" "$8" "$9"
			End

			It "should sort entries by $1${2:+ with -s $2}${3:+ -S $3} (xml)"
				When run source "$SCRIPT" -O xml ${2:+-s "$2"} ${3:+-S "$3"} "$TESTDIR"

				The status should be success
				The path xml-index should be a file
				The path xml-index should not be an empty file

				The contents of path xml-index should satisfy has_order xml "$4" "$5" "$6" "$7" "$8" "$9"
			End

			It "should sort entries by $1${2:+ with -s $2}${3:+ -S $3} (json)"
				When run source "$SCRIPT" -O json ${2:+-s "$2"} ${3:+-S "$3"} "$TESTDIR"

				The status should be success
				The path json-index should be a file
				The path json-index should not be an empty file

				The contents of path json-index should satisfy has_order json "$4" "$5" "$6" "$7" "$8" "$9"
			End
		End

		Describe "secondary by name"
			setup_example() {
				touch "$TESTDIR/a"; touch "$TESTDIR/c"
				mkdir "$TESTDIR/b"; mkdir "$TESTDIR/d"
				for i in b c d; do touch -m -r "$TESTDIR/a" "$TESTDIR/$i"; done
			}
			BeforeEach "setup_example"

			Parameters
				"ascending, folders mixed"   ""                     a   b/  c   d/
				"ascending, folders mixed"   asc                    a   b/  c   d/
				"descending, folders mixed"  desc                   d/  c   b/  a
				"ascending, folders mixed"   no-folders-first       a   b/  c   d/
				"ascending, folders first"   folders-first          b/  d/  a   c
				"ascending, folders mixed"   asc,no-folders-first   a   b/  c   d/
				"descending, folders mixed"  desc,no-folders-first  d/  c   b/  a
				"ascending, folders first"   asc,folders-first      b/  d/  a   c
				"descending, folders first"  desc,folders-first     d/  b/  c   a
			End

			It "should sort entries $1${2:+ with -S $2} (html)"
				When run source "$SCRIPT" -O html -s modified ${2:+-S "$2"} "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should satisfy has_order html "$3" "$4" "$5" "$6"
			End

			It "should sort entries $1${2:+ with -S $2} (xml)"
				When run source "$SCRIPT" -O xml -s modified ${2:+-S "$2"} "$TESTDIR"

				The status should be success
				The path xml-index should be a file
				The path xml-index should not be an empty file

				The contents of path xml-index should satisfy has_order xml "$3" "$4" "$5" "$6"
			End

			It "should sort entries $1${2:+ with -S $2} (json)"
				When run source "$SCRIPT" -O json -s modified ${2:+-S "$2"} "$TESTDIR"

				The status should be success
				The path json-index should be a file
				The path json-index should not be an empty file

				The contents of path json-index should satisfy has_order json "$3" "$4" "$5" "$6"
			End
		End

		Describe "name sort options"
			setup_example() {
				touch "$TESTDIR/aa"
				for i in Ab2.10 Ab2.2 Ab10 Ab1; do touch -r "$TESTDIR/aa" "$TESTDIR/$i"; done;
			}
			BeforeEach "setup_example"
			BeforeEach "export LC_ALL=C"

			# workaround for https://github.com/uutils/coreutils/issues/15463
			sort() {
				@sort "$@"
			}
			Mock uu-sort
			End

			Parameters
				"ascending, version sort, case sensitive"              ""                       Ab1    Ab2.2   Ab2.10  Ab10    aa
				"ascending, version sort, case sensitive"              asc                      Ab1    Ab2.2   Ab2.10  Ab10    aa
				"descending, version sort, case sensitive"             desc                     aa     Ab10    Ab2.10  Ab2.2   Ab1
				"ascending, version sort, case sensitive"              version                  Ab1    Ab2.2   Ab2.10  Ab10    aa
				"ascending, lexicographical order, case sensitive"     no-version               Ab1    Ab10    Ab2.10  Ab2.2   aa
				"ascending, version sort, case sensitive"              case                     Ab1    Ab2.2   Ab2.10  Ab10    aa
				"ascending, version sort, case insensitive"            no-case                  aa     Ab1     Ab2.2   Ab2.10  Ab10
				"ascending, version sort, case sensitive"              asc,version              Ab1    Ab2.2   Ab2.10  Ab10    aa
				"descending, version sort, case sensitive"             desc,version             aa     Ab10    Ab2.10  Ab2.2   Ab1
				"ascending, lexicographical order, case sensitive"     asc,no-version           Ab1    Ab10    Ab2.10  Ab2.2   aa
				"descending, lexicographical order, case sensitive"    desc,no-version          aa     Ab2.2   Ab2.10  Ab10    Ab1
				"ascending, version sort, case sensitive"              asc,case                 Ab1    Ab2.2   Ab2.10  Ab10    aa
				"descending, version sort, case sensitive"             desc,case                aa     Ab10    Ab2.10  Ab2.2   Ab1
				"ascending, version sort, case insensitive"            asc,no-case              aa     Ab1     Ab2.2   Ab2.10  Ab10
				"descending, version sort, case insensitive"           desc,no-case             Ab10   Ab2.10  Ab2.2   Ab1     aa
				"ascending, version sort, case sensitive"              version,case             Ab1    Ab2.2   Ab2.10  Ab10    aa
				"ascending, lexicographical order, case sensitive"     no-version,case          Ab1    Ab10    Ab2.10  Ab2.2   aa
				"ascending, version sort, case insensitive"            version,no-case          aa     Ab1     Ab2.2   Ab2.10  Ab10
				"ascending, lexicographical order, case insensitive"   no-version,no-case       aa     Ab1     Ab10    Ab2.10  Ab2.2
				"ascending, version sort, case sensitive"              asc,version,case         Ab1    Ab2.2   Ab2.10  Ab10    aa
				"descending, version sort, case sensitive"             desc,version,case        aa     Ab10    Ab2.10  Ab2.2   Ab1
				"ascending, lexicographical order, case sensitive"     asc,no-version,case      Ab1    Ab10    Ab2.10  Ab2.2   aa
				"descending, lexicographical order, case sensitive"    desc,no-version,case     aa     Ab2.2   Ab2.10  Ab10    Ab1
				"ascending, version sort, case insensitive"            asc,version,no-case      aa     Ab1     Ab2.2   Ab2.10  Ab10
				"descending, version sort, case insensitive"           desc,version,no-case     Ab10   Ab2.10  Ab2.2   Ab1     aa
				"ascending, lexicographical order, case insensitive"   asc,no-version,no-case   aa     Ab1     Ab10    Ab2.10  Ab2.2
				"descending, lexicographical order, case insensitive"  desc,no-version,no-case  Ab2.2  Ab2.10  Ab10    Ab1     aa
			End

			It "should sort entries primary by name $1${2:+ with -S $2} (html)"
				When run source "$SCRIPT" -O html -s name ${2:+-S "$2"} "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should satisfy has_order html "$3" "$4" "$5" "$6" "$7"
			End

			It "should sort entries primary by name $1${2:+ with -S $2} (xml)"
				When run source "$SCRIPT" -O xml -s name ${2:+-S "$2"} "$TESTDIR"

				The status should be success
				The path xml-index should be a file
				The path xml-index should not be an empty file

				The contents of path xml-index should satisfy has_order xml "$3" "$4" "$5" "$6" "$7"
			End

			It "should sort entries primary by name $1${2:+ with -S $2} (json)"
				When run source "$SCRIPT" -O json -s name ${2:+-S "$2"} "$TESTDIR"

				The status should be success
				The path json-index should be a file
				The path json-index should not be an empty file

				The contents of path json-index should satisfy has_order json "$3" "$4" "$5" "$6" "$7"
			End

			It "should sort entries secondary by name $1${2:+ with -S $2} (html)"
				When run source "$SCRIPT" -O html -s size ${2:+-S "$2"} "$TESTDIR"

				The status should be success
				The path testdir-index should be a file
				The path testdir-index should not be an empty file

				The contents of path testdir-index should satisfy has_order html "$3" "$4" "$5" "$6" "$7"
			End

			It "should sort entries secondary by name $1${2:+ with -S $2} (xml)"
				When run source "$SCRIPT" -O xml -s size ${2:+-S "$2"} "$TESTDIR"

				The status should be success
				The path xml-index should be a file
				The path xml-index should not be an empty file

				The contents of path xml-index should satisfy has_order xml "$3" "$4" "$5" "$6" "$7"
			End

			It "should sort entries secondary by name $1${2:+ with -S $2} (json)"
				When run source "$SCRIPT" -O json -s size ${2:+-S "$2"} "$TESTDIR"

				The status should be success
				The path json-index should be a file
				The path json-index should not be an empty file

				The contents of path json-index should satisfy has_order json "$3" "$4" "$5" "$6" "$7"
			End
		End

		Describe "sort property"
			Describe "whitespace around keyword"
				setup_example() {
					%printf '' > "$TESTDIR/b"
					%printf '##' > "$TESTDIR/a"
					%printf '#' > "$TESTDIR/c"
				}
				BeforeEach "setup_example"

				Parameters:value html xml json

				It "should strip leading whitespace ($1)"
					ht="$SHELLSPEC_HT"
					lf="$SHELLSPEC_LF"
					vt="$SHELLSPEC_VT"
					ff="$SHELLSPEC_FF"
					cr="$SHELLSPEC_CR"
					sp=" "

					When run source "$SCRIPT" -O "$1" -s "${cr}${lf}size" -S desc "$TESTDIR"

					The status should be success
					The path "$TESTDIR/index.$1" should be a file
					The path "$TESTDIR/index.$1" should not be an empty file

					The contents of path "$TESTDIR/index.$1" should satisfy has_order "$1" a c b
				End

				It "should strip trailing whitespace ($1)"
					ht="$SHELLSPEC_HT"
					lf="$SHELLSPEC_LF"
					vt="$SHELLSPEC_VT"
					ff="$SHELLSPEC_FF"
					cr="$SHELLSPEC_CR"
					sp=" "

					When run source "$SCRIPT" -O "$1" -s "size${vt}${ht}" -S desc "$TESTDIR"

					The status should be success
					The path "$TESTDIR/index.$1" should be a file
					The path "$TESTDIR/index.$1" should not be an empty file

					The contents of path "$TESTDIR/index.$1" should satisfy has_order "$1" a c b
				End
			End

			Describe "invalid sort property"
				Parameters:value html xml json

				It "should show an error ($1)"
					When run source "$SCRIPT" -O "$1" -s invalid "$TESTDIR"

					The status should be failure
					The error should equal "$SCRIPT_NAME: error: \"invalid\" is not a valid sort property"
					The path "$TESTDIR/index.$1" should not exist
				End
			End
		End

		Describe "sort options"
			Describe "whitespace around keywords"
				setup_example() { for i in 2.2 2.10 10 1; do touch "$TESTDIR/$i"; done; }
				BeforeEach "setup_example"

				Parameters:value html xml json

				It "should strip leading whitespace ($1)"
					ht="$SHELLSPEC_HT"
					lf="$SHELLSPEC_LF"
					vt="$SHELLSPEC_VT"
					ff="$SHELLSPEC_FF"
					cr="$SHELLSPEC_CR"
					sp=" "

					When run source "$SCRIPT" -O "$1" -S "${vt}desc,${ht}${sp}no-version" "$TESTDIR"

					The status should be success
					The path "$TESTDIR/index.$1" should be a file
					The path "$TESTDIR/index.$1" should not be an empty file

					The contents of path "$TESTDIR/index.$1" should satisfy has_order "$1" 2.2 2.10 10 1
				End

				It "should strip trailing whitespace ($1)"
					ht="$SHELLSPEC_HT"
					lf="$SHELLSPEC_LF"
					vt="$SHELLSPEC_VT"
					ff="$SHELLSPEC_FF"
					cr="$SHELLSPEC_CR"
					sp=" "

					When run source "$SCRIPT" -O "$1" -S "desc${cr}${ff},no-version${lf}" "$TESTDIR"

					The status should be success
					The path "$TESTDIR/index.$1" should be a file
					The path "$TESTDIR/index.$1" should not be an empty file

					The contents of path "$TESTDIR/index.$1" should satisfy has_order "$1" 2.2 2.10 10 1
				End
			End

			Describe "invalid sort option"
				Parameters:value html xml json

				It "should show an error ($1)"
					When run source "$SCRIPT" -O "$1" -S invalid "$TESTDIR"

					The status should be failure
					The error should equal "$SCRIPT_NAME: error: \"invalid\" is not a valid sort option"
					The path "$TESTDIR/index.$1" should not exist
				End
			End
		End
	End

	Describe "directory mtimes"
		is_unmodified() {
			dir="${is_unmodified:?}"
			! [ "$dir" -nt "$dir/ref" ] && ! [ "$dir" -ot "$dir/ref" ]
		}
		is_newer() {
			dir="${is_newer:?}"
			[ "$dir" -nt "$dir/ref" ]
		}
		setup_example() {
			touch "$TESTDIR/ref"
			mkdir "$TESTDIR/dir"
			touch "$TESTDIR/dir/ref"
			touch -m -r "$TESTDIR" "$TESTDIR/ref"
			touch -m -r "$TESTDIR/dir" "$TESTDIR/dir/ref"
			%sleep 1
		}
		BeforeEach "setup_example"

		It "should preserve directory modification times by default"
			When run source "$SCRIPT" "$TESTDIR"

			The status should be success

			The path "$TESTDIR" should satisfy is_unmodified
			The path "$TESTDIR/dir" should satisfy is_unmodified
		End

		It "should update directory modification times with -F"
			When run source "$SCRIPT" -F "$TESTDIR"

			The status should be success

			The path "$TESTDIR" should satisfy is_newer
			The path "$TESTDIR/dir" should satisfy is_newer
		End
	End
End
