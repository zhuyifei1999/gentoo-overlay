# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit cmake

DESCRIPTION="NVIDIA GPUs htop like monitoring tool"
HOMEPAGE="https://github.com/syllo/nvtop"

if [[ ${PV} =~ [9]{4,} ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/syllo/${PN}.git"
else
	SRC_URI="https://github.com/syllo/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
fi

LICENSE="GPL-3"
SLOT="0"
IUSE="video_cards_amdgpu video_cards_nvidia"

DEPEND="
	sys-libs/ncurses:=[tinfo]
	video_cards_amdgpu? ( x11-libs/libdrm[video_cards_amdgpu] )
"
BDEPEND=""
RDEPEND="${DEPEND}
	video_cards_nvidia? ( x11-drivers/nvidia-drivers[X] )
"

RESTRICT="test"

src_configure() {
	local mycmakeargs=(
		-DAMDGPU_SUPPORT=$(usex video_cards_amdgpu)
		-DNVIDIA_SUPPORT=$(usex video_cards_nvidia)
	)
	cmake_src_configure
}
