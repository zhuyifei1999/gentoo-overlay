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
SRC_URI="https://drivers.pantum.com/userfiles/files/download/drive/Pantum%20Ubuntu%20Driver%20V${PV//./_}.zip"
KEYWORDS="~amd64 ~x86"

S=${WORKDIR}

QA_PREBUILT="usr/libexec/cups/filter/*"
QA_PRESTRIPPED="usr/libexec/cups/filter/*"

src_unpack() {
	default || die

	if use x86; then
		unpack_deb "Pantum Ubuntu Driver V${PV}/Resources/pantum_1.1.101-1_i386.deb" || die
	elif use amd64; then
		unpack_deb "Pantum Ubuntu Driver V${PV}/Resources/pantum_1.1.106-1_amd64.deb" || die
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
