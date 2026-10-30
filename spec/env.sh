#
# env.sh
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
