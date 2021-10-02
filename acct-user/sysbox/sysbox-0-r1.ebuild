#Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit acct-user

DESCRIPTION="user for sysbox"
ACCT_USER_ID=-1
ACCT_USER_GROUPS=( sysbox )

acct-user_add_deps
