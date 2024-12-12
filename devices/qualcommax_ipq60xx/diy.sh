#!/bin/bash

shopt -s extglob

SHELL_FOLDER=$(dirname $(readlink -f "$0"))

rm -rf package/firmware package/boot/uboot-envtools target/linux/qualcommax

git_clone_path openwrt-24.10 https://github.com/LiBwrt-op/openwrt-6.x package/firmware package/boot/uboot-envtools target/linux/qualcommax

wget -N https://github.com/openwrt/openwrt/raw/refs/heads/openwrt-24.10/target/linux/qualcommax/ipq60xx/target.mk -P target/linux/qualcommax/ipq60xx/

rm -rf target/linux/qualcommax/patches-6.6/06*-qca-*.patch

#安装luci-app-daed
git clone https://github.com/QiuSimons/luci-app-daed package/dae

#get the libcron （daed依赖）
mkdir -p Package/libcron && wget -O Package/libcron/Makefile https://raw.githubusercontent.com/immortalwrt/packages/refs/heads/master/libs/libcron/Makefile

#修改内核大小为8MB
sed -i '58s/6144/8192/' target/linux/qualcommax/image/ipq60xx.mk

#修改UPnP 菜单名
sed -i "s/UPnP IGD & PCP\/NAT-PMP/UPnP/g" feeds/luci/applications/luci-app-upnp/root/usr/share/luci/menu.d/luci-app-upnp.json
