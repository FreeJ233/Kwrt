#!/bin/bash

shopt -s extglob

SHELL_FOLDER=$(dirname $(readlink -f "$0"))

rm -rf package/firmware package/boot/uboot-envtools target/linux/qualcommax

git_clone_path openwrt-24.10 https://github.com/LiBwrt-op/openwrt-6.x package/firmware package/boot/uboot-envtools target/linux/qualcommax

wget -N https://github.com/openwrt/openwrt/raw/refs/heads/openwrt-24.-/target/linux/qualcommax/ipq60xx/target.mk -P target/linux/qualcommax/ipq60xx/

rm -rf target/linux/qualcommax/patches-6.6/06*-qca-*.patch

#安装luci-app-daed
git clone https://github.com/QiuSimons/luci-app-daed package/dae

#get the libcron （daed依赖）
mkdir -p Package/libcron && wget -O Package/libcron/Makefile https://raw.githubusercontent.com/immortalwrt/packages/refs/heads/master/libs/libcron/Makefile

# 检查当前目录是否为 OpenWrt 源码根目录
if [ ! -f "feeds.conf.default" ]; then
  echo "请确保在 OpenWrt 源码根目录下运行此脚本！"
  exit 1
fi

# 定义要追加的内容
MODULE_DEFINITION='

define KernelPackage/xdp-sockets-diag
  SUBMENU:=$(NETWORK_SUPPORT_MENU)
  TITLE:=PF_XDP sockets monitoring interface support for ss utility
  KCONFIG:= \
    CONFIG_XDP_SOCKETS=y \
    CONFIG_XDP_SOCKETS_DIAG
  FILES:=$(LINUX_DIR)/net/xdp/xsk_diag.ko
  AUTOLOAD:=$(call AutoLoad,31,xsk_diag)
endef

define KernelPackage/xdp-sockets-diag/description
 Support for PF_XDP sockets monitoring interface used by the ss tool
endef

$(eval $(call KernelPackage,xdp-sockets-diag))
'

CONFIG_OPTION='

CONFIG_PACKAGE_kmod-xdp-sockets-diag=y
'

# 将模块定义追加到 netsupport.mk 文件
NETSUPPORT_FILE="package/kernel/linux/modules/netsupport.mk"
if ! grep -q "KernelPackage/xdp-sockets-diag" "$NETSUPPORT_FILE"; then
  echo "追加模块定义到 $NETSUPPORT_FILE..."
  echo "$MODULE_DEFINITION" >> "$NETSUPPORT_FILE"
else
  echo "模块定义已存在于 $NETSUPPORT_FILE，无需重复添加。"
fi

# 将配置选项追加到 .config 文件
CONFIG_FILE=".config"
if ! grep -q "CONFIG_PACKAGE_kmod-xdp-sockets-diag=y" "$CONFIG_FILE"; then
  echo "追加配置选项到 $CONFIG_FILE..."
  echo "$CONFIG_OPTION" >> "$CONFIG_FILE"
else
  echo "配置选项已存在于 $CONFIG_FILE，无需重复添加。"
fi

# 提示用户
echo "脚本执行完毕，请使用 'make menuconfig' 检查配置是否正确。"
