# https://en.wikipedia.org/wiki/Uname#Examples
# https://superuser.com/a/1749811

IS_WINDOWS=

case "$(uname)" in
	CYGWIN*|MINGW*|MSYS*|Windows*) IS_WINDOWS=1 ;;
esac

if [ -z "$IS_WINDOWS" ]; then
	if wslinfo --networking-mode >/dev/null 2>&1 ||
			[ -f /proc/sys/fs/binfmt_misc/WSLInterop ] ||
			[ -n "${WSL_DISTRO_NAME:-}" ] ||
			grep -qs WSL /proc/sys/kernel/osrelease; then
		IS_WINDOWS=1
	fi
fi

export IS_WINDOWS
