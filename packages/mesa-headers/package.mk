################################################################################
#      This file is part of OpenELEC - http://www.openelec.tv
#      Copyright (C) 2009-2014 Stephan Raue (stephan@openelec.tv)
#
#  OpenELEC is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 2 of the License, or
#  (at your option) any later version.
#
#  OpenELEC is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with OpenELEC.  If not, see <http://www.gnu.org/licenses/>.
################################################################################

PKG_NAME="mesa-headers"
PKG_VERSION="11.0.0"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="OSS"
PKG_SITE="http://www.mesa3d.org/"
PKG_URL="ftp://freedesktop.org/pub/mesa/$PKG_VERSION/mesa-$PKG_VERSION.tar.xz"
PKG_DEPENDS_TARGET="toolchain"
PKG_PRIORITY="optional"
PKG_SECTION="devel"
PKG_SHORTDESC="Mesa headers for Mali"
PKG_LONGDESC="Mesa headers for Mali"
PKG_SOURCE_DIR="mesa-$PKG_VERSION"
PKG_SOURCE_NAME="mesa-$PKG_VERSION.tar.xz"

PKG_IS_ADDON="no"
PKG_AUTORECONF="no"

configure_host() {
  : # nothing
}
make_host() {
  : # nothing
}

makeinstall_host() {
  mkdir -p $SYSROOT_PREFIX/usr/include
    cp -PvR $ROOT/$PKG_BUILD/include/EGL $SYSROOT_PREFIX/usr/include
    cp -PvR $ROOT/$PKG_BUILD/include/GLES2 $SYSROOT_PREFIX/usr/include
    cp -Pvr $ROOT/$PKG_BUILD/include/KHR $SYSROOT_PREFIX/usr/include
}
