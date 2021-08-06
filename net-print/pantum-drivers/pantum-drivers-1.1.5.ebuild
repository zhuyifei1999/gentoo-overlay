# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit unpacker

DESCRIPTION="CUPS drivers for Pantum series printer"
HOMEPAGE="https://global.pantum.com/global/drive_tag/drive/"

LICENSE="Proprietary"
SLOT="0"
RESTRICT="strip"

DEPEND=""
RDEPEND=""

SRC_URI="https://global.pantum.com/global/wp-content/uploads/2017/03/Pantum-Ubuntu-Driver-V${PV//./-}.tar.gz"
KEYWORDS="~amd64 ~x86"

S=${WORKDIR}

src_unpack() {
	default || die

	if use x86; then
		unpack_deb "Pantum Ubuntu Driver V${PV}/Resources/pantum-${PV}-i386.deb" || die
	elif use amd64; then
		unpack_deb "Pantum Ubuntu Driver V${PV}/Resources/pantum-${PV}-amd64.deb" || die
	else
		die "Unsupported arch"
	fi
}

src_install() {
	exeinto /usr/libexec/cups/filter/
	doexe usr/lib/cups/filter/*

	dodoc usr/share/doc/pantum/*

	insinto /usr/share/cups/model/
	doins -r usr/share/cups/model/Pantum
}
