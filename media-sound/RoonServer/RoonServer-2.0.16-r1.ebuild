# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
inherit systemd


DESCRIPTION="THE ULTIMATE MUSIC PLAYER FOR MUSIC FANATICS"
HOMEPAGE="https://roonlabs.com"
SRC_URI="http://download.roonlabs.com/builds/RoonServer_linuxx64.tar.bz2  -> ${PF}.tar.bz2"

LICENSE="roonlabs"

SLOT="0"
KEYWORDS="~amd64"
RESTRICT="mirror bindist"

IUSE="systemd samba ffmpeg system-dotnet web alsa rt +taskset4"

RDEPEND="dev-libs/icu
	 alsa? ( media-libs/alsa-lib )
         samba? ( net-fs/cifs-utils )
	 ffmpeg? ( media-video/ffmpeg )
         system-dotnet? ( || ( dev-dotnet/dotnet-sdk-bin:6.0 dev-dotnet/dotnet-runtime:6.0 ) )
"

DEPEND="${RDEPEND}"

S="${WORKDIR}"

src_prepare() {
  default
  if use system-dotnet; then
    rm -vrf "${S}"/RoonServer/RoonDotnet/* || die
    ln -sf /usr/bin/dotnet "${S}"/RoonServer/RoonDotnet/dotnet || die
  fi
  if ! use samba; then
    rm -vrf "${S}"/RoonServer/Appliance/roon_smb_watcher || die
  fi
  if ! use web; then
    rm -vrf "${S}"/RoonServer/*/*.otf || die
    rm -vrf "${S}"/RoonServer/*/*.ttf || die
    rm -vrf "${S}"/RoonServer/Appliance/webroot || die
  fi
  if ! use alsa; then
    rm -vrf "${S}"/RoonServer/Appliance/check_alsa || die
    rm -vrf "${S}"/RoonServer/Appliance/libraatmanager.so || die
  fi
  if use taskset4; then
    cp "${S}"/RoonServer/Appliance/RoonAppliance "${S}"/RoonServer/Appliance/RoonAppliance.orig
    sed -i 's/exec "$HARDLINK" "$SCRIPT.dll" "$@"/exec taskset -c 1,2,3 "$HARDLINK" "$SCRIPT.dll" "$@"/g' \
      "${S}"/RoonServer/Appliance/RoonAppliance
    cp "${S}"/RoonServer/Appliance/RAATServer "${S}"/RoonServer/Appliance/RAATServer.orig
    sed -i 's/exec "$HARDLINK" "$SCRIPT.dll" "$@"/exec taskset -c 0 "$HARDLINK" "$SCRIPT.dll" "$@"/g' \
      "${S}"/RoonServer/Appliance/RAATServer
    cp "${S}"/RoonServer/Server/RoonServer "${S}"/RoonServer/Server/RoonServer.orig
    sed -i 's/exec "$HARDLINK" "$SCRIPT.dll" "$@"/exec taskset -c 0 "$HARDLINK" "$SCRIPT.dll" "$@"/g' \
      "${S}"/RoonServer/Server/RoonServer
  fi
}

src_install() {
  insinto "/opt/${PN}/"
  insopts -m755
  doins -r RoonServer/*
  if use systemd; then
    systemd_dounit "${FILESDIR}/roonserver.service"
  elif use rt; then
    newinitd "${FILESDIR}/roonserver.init.d.rt" "roonserver"
  else
    newinitd "${FILESDIR}/roonserver.init.d" "roonserver"
  fi
}
