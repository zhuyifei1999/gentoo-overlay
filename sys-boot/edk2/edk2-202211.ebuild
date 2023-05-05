# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Somewhat adapted from https://github.com/gentoo/gentoo/pull/17627/files

EAPI=7

inherit multiprocessing toolchain-funcs

DESCRIPTION="Tianocore UEFI Development kit"
HOMEPAGE="https://github.com/tianocore/tianocore.github.io/wiki/EDK-II"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/tianocore/edk2.git"
	KEYWORDS=""
else
	inherit git-r3
	EGIT_REPO_URI="https://github.com/tianocore/edk2.git"
	EGIT_COMMIT="${PN}-stable${PV}"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="BSD-2"
SLOT="0"
REQUIRED_USE=""
RESTRICT="strip"

RDEPEND=">=dev-lang/nasm-2.14.02
	>=sys-power/iasl-20160729"
DEPEND="${RDEPEND}"
BDEPEND="app-arch/unzip"

# EFI pre-build libs
QA_PREBUILT="
	usr/lib/${P}/ArmPkg/Library/GccLto/*.a
"

pkg_setup() {
	if use x86; then
		EFIARCH=IA32
	elif use amd64; then
		EFIARCH=X64
	fi

	# Select toolchain within predefined ones
	if tc-is-gcc; then
		TOOLCHAIN_TAG="GCC5"
	elif tc-is-clang; then
		TOOLCHAIN_TAG="CLANG38"
	else
		TOOLCHAIN_TAG="ELFGCC"
	fi
}

src_configure() {
	sed -e '/^.*\\\s*$/{:cont;N;/^.*\\\s*$/b cont}' \
		-e "s|^\(BUILD_CFLAGS\s*=\).*$|\1 ${CFLAGS} -MD -fshort-wchar -fno-strict-aliasing -nostdlib -c -fPIC|" \
		-e "s|^\(BUILD_LFLAGS\s*=\).*$|\1 ${LDFLAGS}|" \
		-e "s|^\(BUILD_CXXFLAGS\s*=\).*$|\1 ${CXXFLAGS} -Wno-unused-result|" \
		-i "BaseTools/Source/C/Makefiles/header.makefile" \
		|| die "Failed to update makefile header"
}

src_compile() {
	local make_flags=(
		BUILD_CC="$(tc-getBUILD_CC)"
		BUILD_CXX="$(tc-getBUILD_CXX)"
		BUILD_AS="$(tc-getBUILD_AS)"
		BUILD_AR="$(tc-getBUILD_AR)"
		BUILD_LD="$(tc-getBUILD_LD)"
	)
	emake "${make_flags[@]}" -C BaseTools

	# Update template parameter files
	sed -e "s|^\(ACTIVE_PLATFORM\s*=\).*$|\1 MdeModulePkg/MdeModulePkg.dsc|" \
		-e "s|^\(TARGET\s*=\).*$|\1 RELEASE|" \
		-e "s|^\(TARGET_ARCH\s*=\).*$|\1 ${EFIARCH}|" \
		-e "s|^\(TOOL_CHAIN_TAG\s*=\).*$|\1 ${TOOLCHAIN_TAG}|" \
		-e "s|^\(MAX_CONCURRENT_THREAD_NUMBER\s*=\).*$|\1 $(makeopts_jobs)|" \
		-i "BaseTools/Conf/target.template" || die "Failed to configure target file"

	# Clean unneeded files
	find . -name '*.bat' -o -name '*.exe' -exec rm -f {} \; || die
	find ./BaseTools/Source/C -mindepth 1 -maxdepth 1 \! -name 'bin' -exec rm -rf {} \; || die
	find . -name '.git' -prune -exec rm -rf {} \; || die

	# Upsteam hack (symbolic link) should only be created if needed
	rm "${S}/EmulatorPkg/Unix/Host/X11IncludeHack" || die

	# Create workspace script file
	sed -e "s|{EDK_BASE}|${EPREFIX}/usr/lib/${P}|" \
		"${FILESDIR}"/edk2-workspace.template \
		> "${T}/edk2-workspace" || die "Failed to build edk2-workspace"
}

src_install() {
	dobin "${T}/edk2-workspace"

	# Use mkdir && cp here as doins does not preserve execution bits
	mkdir -p "${ED}/usr/lib/${P}" || die
	cp -pR "${S}"/* "${ED}/usr/lib/${P}" || die
	dosym "${P}" "/usr/lib/${PN}"
}

pkg_postinst() {
	elog "To create a new workspace, execute:"
	elog "    . edk2-workspace [workspace_dir]"
	elog "You can link appropriate packages to your workspace. For example,"
	elog "in order to build MdeModulePkg and examples, you can try:"
	elog "    ln -s \"${EROOT}/usr/lib/${P}/\"Mde{Module,}Pkg ."
	elog "    build -a ${EFIARCH} all"
}
