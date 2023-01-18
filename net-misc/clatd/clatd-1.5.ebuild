# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=7
inherit systemd

DESCRIPTION="clatd - a CLAT / SIIT-DC Edge Relay implementation for Linux"
HOMEPAGE="https://github.com/toreanderson/clatd"
if [[ ${PV} =~ [9]{4,} ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/toreanderson/${PN}.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/toreanderson/${PN}/archive/refs/tags/v${PV}.zip -> ${P}.zip"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="MIT"
SLOT="0"

DEPEND="dev-lang/perl"
RDEPEND="${DEPEND}
	dev-perl/Net-IP
	dev-perl/Net-DNS
	virtual/perl-IO-Socket-IP
	sys-apps/iproute2
	net-firewall/iptables
	net-proxy/tayga
"

src_compile() {
	pod2man --name clatd --center "clatd - a CLAT implementation for Linux" --section 8 README.pod > clatd.8
}

src_install() {
	dosbin clatd
	doman clatd.8

	systemd_newunit scripts/clatd.systemd clatd.service

	exeinto /etc/NetworkManager/dispatcher.d/
	newexe scripts/clatd.networkmanager 50-clatd
}
