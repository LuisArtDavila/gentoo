# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit bash-completion-r1

DESCRIPTION="Screen capture utility using imlib2 library"
HOMEPAGE="https://github.com/resurrecting-open-source-projects/scrot"
SRC_URI="https://github.com/resurrecting-open-source-projects/${PN}/releases/download/${PV}/${P}.tar.gz"

LICENSE="feh LGPL-2+"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ppc ~ppc64 ~riscv ~sparc ~x86"

RDEPEND="
	dev-libs/libbsd
	>=media-libs/giblib-1.2.3
	x11-libs/libXext
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXfixes
	|| (
		media-libs/imlib2[gif]
		media-libs/imlib2[jpeg]
		media-libs/imlib2[png]
		media-libs/imlib2[tiff]
	)
"
DEPEND="
	${RDEPEND}
	x11-base/xorg-proto
"
BDEPEND="
	sys-devel/autoconf-archive
	virtual/pkgconfig
"

DOCS=(
	AUTHORS ChangeLog README.md
)

src_install() {
	default
	
	newbashcomp "${FILESDIR}"/${PN}-1.7.bash-completion ${PN}
}
