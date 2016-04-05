################################################################################
#      This file is part of LibreELEC - http://www.libreelec.tv
#      Copyright (C) 2009-2016
#
#  LibreELEC is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 2 of the License, or
#  (at your option) any later version.
#
#  LibreELEC is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with LibreELEC.  If not, see <http://www.gnu.org/licenses/>.
################################################################################

PKG_NAME="linux-api-headers"
PKG_VERSION="3.19"
PKG_URL="http://www.kernel.org/pub/linux/kernel/v3.0/linux-$PKG_VERSION.tar.xz"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="http://www.kernel.org"
PKG_DEPENDS_HOST="ccache:host"
PKG_PRIORITY="optional"
PKG_SECTION="linux"
PKG_SHORTDESC="linux-api-headers: Linux kernel headers sanitized for development use"
PKG_LONGDESC="linux-api-headers: Linux kernel headers sanitized for development use"
PKG_SOURCE_DIR="linux-$PKG_VERSION"

pre_make_host() {
  make ARCH=$TARGET_KERNEL_ARCH mrproper
}

make_host() {
  make ARCH=$TARGET_KERNEL_ARCH headers_check
}

makeinstall_host() {
  make ARCH=$TARGET_KERNEL_ARCH INSTALL_HDR_PATH=dest headers_install
}

post_makeinstall_host() {
  mkdir -p $SYSROOT_PREFIX/usr/include
  cp -R dest/include/* $SYSROOT_PREFIX/usr/include
}
