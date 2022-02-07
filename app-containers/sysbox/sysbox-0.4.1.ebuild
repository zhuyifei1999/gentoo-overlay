# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit systemd

DESCRIPTION="An open-source, next-generation \"runc\" that empowers rootless containers to run workloads such as Systemd, Docker, Kubernetes, just like VMs"
HOMEPAGE="https://github.com/nestybox/sysbox"

# No submodules
# if [[ ${PV} == *9999 ]] ; then
# 	EGIT_REPO_URI="https://github.com/nestybox/${PN}.git"
# 	inherit git-r3
# else
# 	SRC_URI="https://github.com/nestybox/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
# 	KEYWORDS="~amd64 ~x86"
# fi

EGIT_REPO_URI="https://github.com/nestybox/${PN}.git"
inherit git-r3

EGIT_OVERRIDE_REPO_GIT_GITHUB_COM_NESTYBOX_SYSBOX_FS="https://github.com/nestybox/sysbox-fs.git"
EGIT_OVERRIDE_REPO_GIT_GITHUB_COM_NESTYBOX_FUSE="https://github.com/nestybox/fuse.git"
EGIT_OVERRIDE_REPO_GIT_GITHUB_COM_NESTYBOX_SYSBOX_RUNC="https://github.com/nestybox/sysbox-runc.git"
EGIT_OVERRIDE_REPO_GIT_GITHUB_COM_NESTYBOX_SYSBOX_IPC="https://github.com/nestybox/sysbox-ipc.git"
EGIT_OVERRIDE_REPO_GIT_GITHUB_COM_NESTYBOX_SYSBOX_MGR="https://github.com/nestybox/sysbox-mgr.git"
EGIT_OVERRIDE_REPO_GIT_GITHUB_COM_NESTYBOX_SYSBOX_LIBS="https://github.com/nestybox/sysbox-libs.git"
EGIT_OVERRIDE_REPO_GIT_GITHUB_COM_NESTYBOX_LIBSECCOMP="https://github.com/nestybox/libseccomp.git"
EGIT_OVERRIDE_REPO_GIT_GITHUB_COM_NESTYBOX_LIBSECCOMP_GOLANG="https://github.com/nestybox/libseccomp-golang.git"
EGIT_OVERRIDE_REPO_GIT_GITHUB_COM_NESTYBOX_DOCKERFILES="https://github.com/nestybox/dockerfiles.git"

if [[ ${PV} != *9999 ]] ; then
	EGIT_COMMIT="v${PV}"
	KEYWORDS="~amd64 ~x86"
fi

RESTRICT="network-sandbox"

LICENSE="Apache-2.0"
SLOT="0"

DEPEND="app-containers/docker
	dev-go/go-protobuf
	acct-user/sysbox"
RDEPEND="${DEPEND}"
BDEPEND=""

src_compile() {
	GOPATH="$(pwd)" GOBIN="$(pwd)/bin" \
	emake sysbox-local \
		KERNEL_HEADERS="/lib/modules/$(uname -r)/source/" \
		KERNEL_HEADERS_BASE="/lib/modules/$(uname -r)/source/"
}

src_install() {
	emake DESTDIR="${D}/usr/bin" install

	systemd_dounit "${FILESDIR}"/sysbox.service
	systemd_dounit "${FILESDIR}"/sysbox-fs.service
	systemd_dounit "${FILESDIR}"/sysbox-mgr.service

	insinto /etc/sysctl.d
	newins "${FILESDIR}"/sysctld 90-${PN}.conf

	insinto /usr/lib/modules-load.d
	newins "${FILESDIR}"/modload 90-${PN}.conf

	keepdir /var/lib/sysboxfs

	newsbin scr/docker-cfg sysbox-docker-cfg
}

pkg_postinst() {
	elog "You may need to load sysctls:"
	elog "    sysctl --load=/etc/sysctl.d/90-${PN}.conf"
	elog "You may need configure docker:"
	elog "    sysbox-docker-cfg --sysbox-runtime=enable"
}
