#!/bin/bash

shopt -s extglob

SHELL_FOLDER=$(dirname $(readlink -f "$0"))

#sh -c "curl -sfL https://patch-diff.githubusercontent.com/raw/openwrt/openwrt/pull/10778.patch | git apply -p1"

wget -N https://github.com/immortalwrt/immortalwrt/raw/refs/heads/openwrt-24.10/target/linux/ipq40xx/patches-6.6/991-ipq40xx-unlock-cpu-frequency.patch -P target/linux/ipq40xx/patches-6.6/

# 修改默认IP
sed -i 's/192.168.1/192.168.3/g' package/base-files/files/bin/config_generate

# 更改默认 Shell 为 zsh
# sed -i 's/\/bin\/ash/\/usr\/bin\/zsh/g' package/base-files/files/etc/passwd

# TTYD 免登录
sed -i 's|/bin/login|/bin/login -f root|g' feeds/packages/utils/ttyd/files/ttyd.config



