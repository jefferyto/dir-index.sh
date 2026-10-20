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
