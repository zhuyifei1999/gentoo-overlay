# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 cmake

DESCRIPTION="A custom discord client that supports streaming with audio on Linux"
HOMEPAGE="https://github.com/maltejur/discord-screenaudio"
EGIT_REPO_URI="https://github.com/maltejur/${PN}.git"
EGIT_COMMIT="v${PV}"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="dev-qt/qtwebengine:5
	kde-frameworks/knotifications
	kde-frameworks/kxmlgui
	kde-frameworks/kglobalaccel
	media-video/pipewire"
RDEPEND="${DEPEND}"
BDEPEND=""

src_install() {
	cmake_src_install
	dolib.so "${BUILD_DIR}/submodules/rohrkabel/librohrkabel.so"
}
