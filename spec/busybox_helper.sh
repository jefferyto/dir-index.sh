#
# busybox_helper.sh
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

override_applet() {
	local cmd="$1"
	local oifs="$IFS"
	local cmd_path=
	local p=

	IFS=":"
	for p in $PATH; do
		if [ -x "${p:-.}/$cmd" ]; then
			cmd_path="${p:-.}"
			break
		fi
	done
	IFS="$oifs"

	if [ -n "$cmd_path" ]; then
		eval "$cmd() { \"$cmd_path/$cmd\" \"\$@\"; }"
	fi
}

setup_dependencies() {
	local i=

	for i in date find mktemp numfmt readlink realpath sed sort touch tr; do
		if "$i" --help 2>&1 | grep -qi busybox; then
			override_applet "$i"
		fi
	done
}

# This callback function will be invoked only once before loading specfiles.
busybox_helper_precheck() {
  # Available functions: info, warn, error, abort, setenv, unsetenv
  # Available variables: VERSION, SHELL_TYPE, SHELL_VERSION
  : minimum_version "0.29.0"
}

# This callback function will be invoked after a specfile has been loaded.
busybox_helper_loaded() {
  :
}

# This callback function will be invoked after core modules has been loaded.
busybox_helper_configure() {
  # Available functions: import, before_each, after_each, before_all, after_all
  : import 'support/custom_matcher'

	before_each "setup_dependencies"
}
