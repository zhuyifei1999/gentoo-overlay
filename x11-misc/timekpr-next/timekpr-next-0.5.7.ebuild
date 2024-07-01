# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=8
PYTHON_COMPAT=( python3_{6,7,8,9,10,11,12} )
DISTUTILS_SINGLE_IMPL=1
inherit git-r3 xdg-utils systemd python-single-r1

DESCRIPTION="Timekpr-nExT - Keep control of computer usage"
HOMEPAGE="https://mjasnik.gitlab.io/timekpr-next/"
EGIT_REPO_URI="https://git.launchpad.net/${PN}"
if [[ ${PV} =~ [9]{4,} ]]; then
	EGIT_BRANCH="experimental"
	KEYWORDS=""
else
	EGIT_COMMIT="v${PV}"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL3"
SLOT="0"

DEPEND="
	acct-group/timekpr
	dev-util/desktop-file-utils
	dev-libs/appstream-glib
	sys-apps/systemd
	gui-libs/gtk
	sys-auth/polkit
	$(python_gen_cond_dep '
		dev-python/dbus-python[${PYTHON_USEDEP}]
	')
	$(python_gen_cond_dep '
		dev-python/pygobject[${PYTHON_USEDEP}]
	')
	dev-libs/keybinder
	$(python_gen_cond_dep '
		dev-python/psutil[${PYTHON_USEDEP}]
	')
	|| ( dev-libs/libappindicator dev-libs/libindicator )
	${PYTHON_DEPS}"
RDEPEND="${DEPEND}"

pkg_setup() { python-single-r1_pkg_setup; }

src_compile() {
	SITEDIR=$(python_get_sitedir)
	grep -lr /usr/lib/python3/dist-packages | xargs \
		sed -i "s,/usr/lib/python3/dist-packages,${SITEDIR}," bin/*
}

src_install() {
	dobin bin/*
	python_fix_shebang "${ED}"/usr/bin

	insinto /etc/dbus-1/system.d/
	doins resource/server/dbus/timekpr.conf
	insinto /etc/logrotate.d/
	doins resource/server/logrotate.d/timekpr
	insinto /usr/share/polkit-1/actions/
	doins resource/server/polkit/com.ubuntu.timekpr.pkexec.policy
	systemd_dounit resource/server/systemd/timekpr.service
	insinto /etc/timekpr/
	doins resource/server/timekpr.conf

	insinto /var/lib/timekpr/config/
	doins resource/server/timekpr.USER.conf
	insinto /var/lib/timekpr/work/
	doins resource/server/USER.time

	insinto /usr/share/icons/hicolor/128x128/apps/
	doins resource/icons/timekpr-128.png
	doins resource/icons/timekpr-client-128.png
	insinto /usr/share/icons/hicolor/48x48/apps/
	doins resource/icons/timekpr-48.png
	doins resource/icons/timekpr-client-48.png
	insinto /usr/share/icons/hicolor/64x64/apps/
	doins resource/icons/timekpr-64.png
	doins resource/icons/timekpr-client-64.png
	insinto /usr/share/timekpr/icons/
	doins resource/icons/timekpr-client-logo.svg
	doins resource/icons/timekpr-logo.svg
	doins resource/icons/timekpr-padlock-limited-green.svg
	doins resource/icons/timekpr-padlock-limited-red.svg
	doins resource/icons/timekpr-padlock-limited-yellow.svg
	doins resource/icons/timekpr-padlock-limited-uacc.svg
	doins resource/icons/timekpr-padlock-unlimited-green.svg
	insinto /usr/share/icons/hicolor/scalable/apps/
	doins resource/icons/timekpr-client.svg
	doins resource/icons/timekpr.svg

	insinto /usr/share/applications/
	doins resource/launchers/timekpr-admin.desktop
	doins resource/launchers/timekpr-admin-su.desktop
	insinto /etc/xdg/autostart/
	doins resource/launchers/timekpr-client.desktop

	insinto /usr/share/metainfo/
	doins resource/appstream/org.timekpr.timekpr-next.metainfo.xml

	insinto /usr/share/timekpr/client/forms/
	doins resource/client/forms/about.glade
	doins resource/client/forms/admin.glade
	doins resource/client/forms/client.glade

	python_moduleinto timekpr
	python_domodule common client server

	insinto /usr/share/locale/be/LC_MESSAGES/
	doins resource/locale/be/LC_MESSAGES/timekpr.mo
	insinto /usr/share/locale/de/LC_MESSAGES/
	doins resource/locale/de/LC_MESSAGES/timekpr.mo
	insinto /usr/share/locale/fr/LC_MESSAGES/
	doins resource/locale/fr/LC_MESSAGES/timekpr.mo
	insinto /usr/share/locale/it/LC_MESSAGES/
	doins resource/locale/it/LC_MESSAGES/timekpr.mo
	insinto /usr/share/locale/lv/LC_MESSAGES/
	doins resource/locale/lv/LC_MESSAGES/timekpr.mo
}

pkg_postinst() {
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_icon_cache_update
}
