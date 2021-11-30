# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils user git-r3

MY_PN="shairport-sync"

DESCRIPTION="Shairport Sync is an AirPlay audio player"
HOMEPAGE="https://github.com/mikebrady/shairport-sync"
EGIT_REPO_URI="https://github.com/mikebrady/shairport-sync.git"
EGIT_BRANCH="development"


LICENSE="GPL-2"
SLOT="0"
#KEYWORDS="~amd64 ~x86 ~arm ~arm64"
KEYWORDS=""
IUSE="convolution ap2"

DEPEND="dev-libs/openssl
	media-libs/soxr
	dev-libs/libconfig
	dev-libs/libdaemon
	convolution? ( media-libs/libsndfile )
	ap2? ( app-pda/libplist )
	ap2? ( dev-util/xxd )
	ap2? ( dev-libs/libsodium )
	ap2? ( app-doc/xmltoman )
	ap2? ( net-misc/nqptp )"
RDEPEND="${DEPEND}
	net-dns/avahi"

#S="${WORKDIR}/${MY_PN}"

pkg_setup() {
	enewuser shairport-sync -1 -1 -1 audio
}

src_compile() {
        #default
        autoreconf -fi
				if use convolution; then
				    if use ap2; then
					    ./configure --sysconfdir=/etc --with-alsa --with-soxr --with-avahi --with-ssl=openssl --with-libdaemon --with-convolution --with-airplay-2
						else
						  ./configure --sysconfdir=/etc --with-alsa --with-soxr --with-avahi --with-ssl=openssl --with-libdaemon --with-convolution
						fi
				else
				    if use ap2; then
				     ./configure --sysconfdir=/etc --with-alsa --with-soxr --with-avahi --with-ssl=openssl --with-libdaemon --with-airplay-2
						else
						 ./configure --sysconfdir=/etc --with-alsa --with-soxr --with-avahi --with-ssl=openssl --with-libdaemon
					  fi
				fi
				make
}

src_install() {
	emake DESTDIR="${D}" install
	if use ap2; then
		newinitd "${FILESDIR}"/${MY_PN}-ap2.initd ${MY_PN}
	else
	  newinitd "${FILESDIR}"/${MY_PN}.initd ${MY_PN}
	fi
}
