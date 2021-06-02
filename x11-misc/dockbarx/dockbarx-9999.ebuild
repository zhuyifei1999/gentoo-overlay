# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=7
PYTHON_COMPAT=( python3_{6,7,8,9} )
DISTUTILS_SINGLE_IMPL=1
inherit git-r3 gnome2-utils xdg-utils eutils distutils-r1

DESCRIPTION="DockBarX is a lightweight taskbar / panel replacement for Linux"
HOMEPAGE="https://github.com/xuzhen/dockbarx"
EGIT_REPO_URI="https://github.com/xuzhen/${PN}.git"
EGIT_BRANCH="pygi-python3"

LICENSE="GPL3"
SLOT="0"
KEYWORDS=""

DEPEND="
	$(python_gen_cond_dep '
		dev-python/pygobject:3[cairo,${PYTHON_MULTI_USEDEP}]
	')
	$(python_gen_cond_dep '
		dev-python/pillow[${PYTHON_MULTI_USEDEP}]
	')
	dev-libs/keybinder
	$(python_gen_cond_dep '
		dev-python/dbus-python[${PYTHON_MULTI_USEDEP}]
	')
	$(python_gen_cond_dep '
		dev-python/polib[${PYTHON_MULTI_USEDEP}]
	')
	$(python_gen_cond_dep '
		dev-python/pyxdg[${PYTHON_MULTI_USEDEP}]
	')
	$(python_gen_cond_dep '
		dev-python/python-xlib[${PYTHON_MULTI_USEDEP}]
	')
	${PYTHON_DEPS}"
RDEPEND="${DEPEND}"

pkg_setup() { python-single-r1_pkg_setup; }

python_install() {
	distutils-r1_python_install
	python_fix_shebang "${ED}"/usr/bin
}

pkg_postinst() {
	xdg_icon_cache_update
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_icon_cache_update
	gnome2_schemas_update
}
