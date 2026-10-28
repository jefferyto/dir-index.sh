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
