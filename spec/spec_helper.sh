#
# spec_helper.sh
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

# shellcheck shell=sh

# Defining variables and functions here will affect all specfiles.
# Change shell options inside a function may cause different behavior,
# so it is better to set them here.
# set -eu

# This callback function will be invoked only once before loading specfiles.
spec_helper_precheck() {
  # Available functions: info, warn, error, abort, setenv, unsetenv
  # Available variables: VERSION, SHELL_TYPE, SHELL_VERSION
  : minimum_version "0.29.0"
}

# This callback function will be invoked after a specfile has been loaded.
spec_helper_loaded() {
  :
}

# This callback function will be invoked after core modules has been loaded.
spec_helper_configure() {
  # Available functions: import, before_each, after_each, before_all, after_all
  : import 'support/custom_matcher'

	if [ -z "${SHELLSPEC_SHELL##*busybox*}" ]; then
		import "busybox_helper"
		busybox_helper_configure
	fi
}

setup_testdir() {
	rm -rf "$TESTDIR"
	mkdir -p "$TESTDIR"
}

teardown_testdir() {
	rm -rf "$TESTDIR"
}

is_windows() {
	[ -n "$IS_WINDOWS" ]
}

has_order() {
	local value="${has_order:?}"
	local format="$1"
	local len=
	local prefix=
	local i=
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
