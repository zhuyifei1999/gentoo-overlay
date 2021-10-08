# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=7
PYTHON_COMPAT=( python3_{6,7,8,9,10} )

inherit distutils-r1

DESCRIPTION="Guppy 3 -- A Python Programming Environment"
HOMEPAGE="https://zhuyifei1999.github.io/guppy3/ https://pypi.org/project/guppy3/"

if [[ ${PV} == *9999 ]] ; then
	EGIT_REPO_URI="https://github.com/zhuyifei1999/${PN}.git"
	inherit git-r3
else
	SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="MIT"
SLOT="0"
IUSE="doc"

DEPEND=""
RDEPEND=""

python_test() {
	"${PYTHON}" setup.py build install --home="${T}/test-${EPYTHON}" \
		|| die "Installation of tests failed"
	pushd "${T}/test-${EPYTHON}/lib/python" > /dev/null
	"${PYTHON}" guppy/heapy/test/test_all.py || die "tests failed"
	popd > /dev/null
}

python_install_all() {
	# leave the html docs for install as the setup.py dictates but rm if set by IUSE doc
	if use doc; then
		local HTML_DOCS=( guppy/doc/. )
		find "${D}$(python_get_sitedir)" -name doc | xargs rm -rf
	fi
	distutils-r1_python_install_all
}
