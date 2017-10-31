################################################################################
#      This file is part of LibreELEC - http://www.libreelec.tv
#      Copyright (C) 2012-
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

PKG_NAME="linux"
PKG_VERSION="4.9.51~odroid_xu3+2cb5bd"
PKG_URL="$ODROID_MIRROR/$PKG_NAME-$PKG_VERSION.tar.xz"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="http://www.kernel.org"
PKG_DEPENDS_HOST="linux-api-headers:host"
PKG_DEPENDS_TARGET="toolchain cpio:host kmod:host pciutils xz:host wireless-regdb"
PKG_DEPENDS_INIT="toolchain"
PKG_NEED_UNPACK="$LINUX_DEPENDS"
PKG_PRIORITY="optional"
PKG_SECTION="linux"
PKG_SHORTDESC="linux: The Linux kernel binary image and modules"
PKG_LONGDESC="This package contains a precompiled Linux kernel image and the modules."

PKG_IS_ADDON="no"
PKG_AUTORECONF="no"

post_patch() {
  # copy old compiler-gcc5 over for gcc6 and gcc7
  cp $PKG_BUILD/include/linux/compiler-gcc5.h $PKG_BUILD/include/linux/compiler-gcc6.h
  cp $PKG_BUILD/include/linux/compiler-gcc6.h $PKG_BUILD/include/linux/compiler-gcc7.h


  if [ -n "$DEVICE" -a -f $PROJECT_DIR/$PROJECT/devices/$DEVICE/$PKG_NAME/$PKG_VERSION/$PKG_NAME.$TARGET_ARCH.conf ]; then
    KERNEL_CFG_FILE=$PROJECT_DIR/$PROJECT/devices/$DEVICE/$PKG_NAME/$PKG_VERSION/$PKG_NAME.$TARGET_ARCH.conf
  elif [ -n "$DEVICE" -a -f $PROJECT_DIR/$PROJECT/devices/$DEVICE/$PKG_NAME/$PKG_NAME.$TARGET_ARCH.conf ]; then
    KERNEL_CFG_FILE=$PROJECT_DIR/$PROJECT/devices/$DEVICE/$PKG_NAME/$PKG_NAME.$TARGET_ARCH.conf
  elif [ -f $PROJECT_DIR/$PROJECT/$PKG_NAME/$PKG_VERSION/$PKG_NAME.$TARGET_ARCH.conf ]; then
    KERNEL_CFG_FILE=$PROJECT_DIR/$PROJECT/$PKG_NAME/$PKG_VERSION/$PKG_NAME.$TARGET_ARCH.conf
  elif [ -f $PROJECT_DIR/$PROJECT/$PKG_NAME/$PKG_NAME.$TARGET_ARCH.conf ]; then
    KERNEL_CFG_FILE=$PROJECT_DIR/$PROJECT/$PKG_NAME/$PKG_NAME.$TARGET_ARCH.conf
  elif [ -f $PKG_DIR/config/$PKG_VERSION/$PKG_NAME.$TARGET_ARCH.conf ]; then
    KERNEL_CFG_FILE=$PKG_DIR/config/$PKG_VERSION/$PKG_NAME.$TARGET_ARCH.conf
  else
    KERNEL_CFG_FILE=$PKG_DIR/config/$PKG_NAME.$TARGET_ARCH.conf
  fi

  sed -i -e "s|^HOSTCC[[:space:]]*=.*$|HOSTCC = $TOOLCHAIN/bin/host-gcc|" \
         -e "s|^HOSTCXX[[:space:]]*=.*$|HOSTCXX = $TOOLCHAIN/bin/host-g++|" \
         -e "s|^ARCH[[:space:]]*?=.*$|ARCH = $TARGET_KERNEL_ARCH|" \
         -e "s|^CROSS_COMPILE[[:space:]]*?=.*$|CROSS_COMPILE = $TARGET_PREFIX|" \
         $PKG_BUILD/Makefile

  cp $KERNEL_CFG_FILE $PKG_BUILD/.config
  sed -i -e "s|^CONFIG_INITRAMFS_SOURCE=.*$|CONFIG_INITRAMFS_SOURCE=\"$BUILD/image/initramfs.cpio\"|" $PKG_BUILD/.config

  # set default hostname based on $DISTRONAME
  sed -i -e "s|@DISTRONAME@|$DISTRONAME|g" $PKG_BUILD/.config

  # disable swap support if not enabled
  if [ ! "$SWAP_SUPPORT" = yes ]; then
    sed -i -e "s|^CONFIG_SWAP=.*$|# CONFIG_SWAP is not set|" $PKG_BUILD/.config
  fi

  # disable nfs support if not enabled
  if [ ! "$NFS_SUPPORT" = yes ]; then
    sed -i -e "s|^CONFIG_NFS_FS=.*$|# CONFIG_NFS_FS is not set|" $PKG_BUILD/.config
  fi

  # disable cifs support if not enabled
  if [ ! "$SAMBA_SUPPORT" = yes ]; then
    sed -i -e "s|^CONFIG_CIFS=.*$|# CONFIG_CIFS is not set|" $PKG_BUILD/.config
  fi

  # disable iscsi support if not enabled
  if [ ! "$ISCSI_SUPPORT" = yes ]; then
    sed -i -e "s|^CONFIG_SCSI_ISCSI_ATTRS=.*$|# CONFIG_SCSI_ISCSI_ATTRS is not set|" $PKG_BUILD/.config
    sed -i -e "s|^CONFIG_ISCSI_TCP=.*$|# CONFIG_ISCSI_TCP is not set|" $PKG_BUILD/.config
    sed -i -e "s|^CONFIG_ISCSI_BOOT_SYSFS=.*$|# CONFIG_ISCSI_BOOT_SYSFS is not set|" $PKG_BUILD/.config
    sed -i -e "s|^CONFIG_ISCSI_IBFT_FIND=.*$|# CONFIG_ISCSI_IBFT_FIND is not set|" $PKG_BUILD/.config
    sed -i -e "s|^CONFIG_ISCSI_IBFT=.*$|# CONFIG_ISCSI_IBFT is not set|" $PKG_BUILD/.config
  fi
}

make_host() {
  : # do nothing (we use linux-api-headers)
}

makeinstall_host() {
  : # do nothing (we use linux-api-headers)
}

pre_make_target() {
  make oldconfig

  # regdb
  cp $(get_build_dir wireless-regdb)/db.txt $PKG_BUILD/net/wireless/db.txt

  if [ "$BOOTLOADER" = "u-boot" ]; then
    ( cd $ROOT
      $SCRIPTS/build u-boot
    )
  fi
}

make_target() {
  LDFLAGS="" make modules
  LDFLAGS="" make INSTALL_MOD_PATH=$INSTALL/usr DEPMOD="$TOOLCHAIN/bin/depmod" modules_install
  rm -f $INSTALL/usr/lib/modules/*/build
  rm -f $INSTALL/usr/lib/modules/*/source

  ( cd $ROOT
    rm -rf $BUILD/initramfs
    $SCRIPTS/install initramfs
  )

  if [ "$BOOTLOADER" = "u-boot" -a -n "$KERNEL_UBOOT_EXTRA_TARGET" ]; then
    for extra_target in "$KERNEL_UBOOT_EXTRA_TARGET"; do
      LDFLAGS="" make $extra_target
    done
  fi

  LDFLAGS="" make $KERNEL_TARGET $KERNEL_MAKE_EXTRACMD
}

makeinstall_target() {
  if [ "$BOOTLOADER" = "u-boot" -a -f "$(ls arch/$TARGET_KERNEL_ARCH/boot/dts/*.dtb 2>/dev/null)" ]; then
    mkdir -p $INSTALL/usr/share/bootloader
      cp arch/$TARGET_KERNEL_ARCH/boot/dts/*.dtb $INSTALL/usr/share/bootloader
  fi
}

make_init() {
 : # reuse make_target()
}

makeinstall_init() {
  if [ -n "$INITRAMFS_MODULES" ]; then
    mkdir -p $INSTALL/etc
    mkdir -p $INSTALL/usr/lib/modules

    for i in $INITRAMFS_MODULES; do
      module=`find .install_pkg/usr/lib/modules/$(get_module_dir)/kernel -name $i.ko`
      if [ -n "$module" ]; then
        echo $i >> $INSTALL/etc/modules
        cp $module $INSTALL/usr/lib/modules/`basename $module`
      fi
    done
  fi

  if [ "$UVESAFB_SUPPORT" = yes ]; then
    mkdir -p $INSTALL/usr/lib/modules
      uvesafb=`find .install_pkg/usr/lib/modules/$(get_module_dir)/kernel -name uvesafb.ko`
      cp $uvesafb $INSTALL/usr/lib/modules/`basename $uvesafb`
  fi
}

post_install() {
  mkdir -p $INSTALL/usr/lib/firmware/
    ln -sfn /storage/.config/firmware/ $INSTALL/usr/lib/firmware/updates

  # bluez looks in /etc/firmware/
    ln -sfn /usr/lib/firmware/ $INSTALL/etc/firmware
}
