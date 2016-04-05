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

PKG_NAME="samsung-firmware"
PKG_VERSION="20141026.0e5f637"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE=""
PKG_SITE="http://git.kernel.org/cgit/linux/kernel/git/firmware/linux-firmware.git"
PKG_URL="$ODROID_MIRROR/$PKG_NAME-$PKG_VERSION.tar.xz"
PKG_DEPENDS_TARGET="toolchain"
PKG_PRIORITY="optional"
PKG_SECTION="firmware"
PKG_SHORTDESC="samsung-firmware: firmwares for various samsung devices"
PKG_LONGDESC="samsung-firmware: firmwares for various samsung devices"

PKG_IS_ADDON="no"
PKG_AUTORECONF="no"

make_target() {
  : # nothing todo
}

makeinstall_target() {
  mkdir -p $INSTALL/lib/firmware/s5p-mfc
  cp -R * $INSTALL/lib/firmware
  for fw in s5p-* ; do
    ln -sf ../${fw} $INSTALL/lib/firmware/s5p-mfc/${fw}
  done
}
