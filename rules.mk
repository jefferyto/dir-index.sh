#
# rules.mk
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

SUFFIXES = -in

# https://www.gnu.org/software/make/manual/html_node/Directory-Variables.html
# https://www.gnu.org/software/automake/manual/html_node/Uniform.html#index-pkgdatadir
# https://www.gnu.org/savannah-checkouts/gnu/autoconf/manual/autoconf-2.73/html_node/Initializing-configure.html#index-PACKAGE_005fNAME
.sh-in.sh:
	sed \
	 -e 's,[@]prefix[@],$(prefix),g' \
	 -e 's,[@]exec_prefix[@],$(exec_prefix),g' \
	 -e 's,[@]bindir[@],$(bindir),g' \
	 -e 's,[@]sbindir[@],$(sbindir),g' \
	 -e 's,[@]libexecdir[@],$(libexecdir),g' \
	 -e 's,[@]datarootdir[@],$(datarootdir),g' \
	 -e 's,[@]datadir[@],$(datadir),g' \
	 -e 's,[@]sysconfdir[@],$(sysconfdir),g' \
	 -e 's,[@]sharedstatedir[@],$(sharedstatedir),g' \
	 -e 's,[@]localstatedir[@],$(localstatedir),g' \
	 -e 's,[@]pkgdatadir[@],$(pkgdatadir),g' \
	 -e 's,[@]pkglibexecdir[@],$(pkglibexecdir),g' \
	 -e 's,[@]PACKAGE_NAME[@],$(PACKAGE_NAME),g' \
	 -e 's,[@]PACKAGE_TARNAME[@],$(PACKAGE_TARNAME),g' \
	 -e 's,[@]PACKAGE_VERSION[@],$(PACKAGE_VERSION),g' \
	 -e 's,[@]PACKAGE_BUGREPORT[@],$(PACKAGE_BUGREPORT),g' \
	 -e 's,[@]PACKAGE_URL[@],$(PACKAGE_URL),g' \
	 $< > $@

.sh:
	cp $< $@
