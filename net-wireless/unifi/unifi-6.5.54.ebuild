# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# Set this var for any releases except stable
RC_SUFFIX="-3b5d40203c"

inherit systemd

DESCRIPTION="A Management Controller for Ubiquiti Networks UniFi APs"
HOMEPAGE="https://www.ubnt.com"
SRC_URI="https://dl.ui.com/unifi/${PV}${RC_SUFFIX}/UniFi.unix.zip -> ${P}.zip"

KEYWORDS="-* ~amd64 ~arm64"
LICENSE="Apache-1.0 Apache-2.0 BSD-1 BSD-2 BSD CDDL EPL-1.0 GPL-2 LGPL-2.1 LGPL-3 MIT ubiquiti"
SLOT="0/$(ver_cut 1-2)"
IUSE="systemd"

RDEPEND="
	acct-group/unifi
	acct-user/unifi
	dev-db/mongodb
	virtual/jre:1.8
"

DEPEND="app-arch/unzip"

RESTRICT="bindist mirror"

S="${WORKDIR}/UniFi"

DOCS=( "readme.txt" )

QA_PREBUILT="usr/lib/unifi/lib/native/Linux/x86_64/*.so"

src_prepare() {
	# Remove unneeded files Mac and Windows
	rm -r lib/native/{Mac,Windows} || die

	if [[ ${CHOST} != aarch64* ]]; then
		rm -r lib/native/Linux/aarch64 || die "Failed in removing aarch64 native libraries"
	fi
	if [[ ${CHOST} != armv7* ]]; then
		rm -r lib/native/Linux/armv7 || die "Failed in removing armv7 native libraries"
	fi
	if [[ ${CHOST} != x86_64* ]]; then
		rm -r lib/native/Linux/x86_64 || die "Failed in removing x86_64 native libraries"
	fi

	if [[ ${CHOST} == aarch64* ]]; then
		if ! use systemd; then
			rm lib/native/Linux/aarch64/libubnt_sdnotify_jni.so || die
		fi
	fi
	if [[ ${CHOST} == armv7* ]]; then
		if ! use systemd; then
			rm lib/native/Linux/armv7/libubnt_sdnotify_jni.so || die
		fi
	fi
	if [[ ${CHOST} == x86_64* ]]; then
		if ! use systemd; then
			rm lib/native/Linux/x86_64/libubnt_sdnotify_jni.so || die
		fi
	fi

	default
}

src_install() {
	insinto /usr/lib/unifi
	doins -r bin dl lib webapps

	diropts -o unifi -g unifi
	keepdir /var/lib/unifi/{conf,data,run,tmp,work} /var/log/unifi

	for symlink in conf data run tmp work; do
		dosym ../../../var/lib/unifi/${symlink} /usr/lib/unifi/${symlink}
	done
	dosym ../../../var/log/unifi /usr/lib/unifi/logs

	newinitd "${FILESDIR}"/unifi.initd-r1 unifi
	systemd_dounit "${FILESDIR}"/unifi.service

	newconfd "${FILESDIR}"/unifi.confd unifi

	echo 'CONFIG_PROTECT="/var/lib/unifi"' > "${T}"/99unifi || die
	doenvd "${T}"/99unifi

	einstalldocs
}
