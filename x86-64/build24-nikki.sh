#!/bin/bash

source shell/custom-packages.sh
source shell/switch_repository.sh

LOGFILE="/tmp/uci-defaults-log.txt"
echo "Starting build24-nikki.sh at $(date)" >> $LOGFILE

mkdir -p /home/build/immortalwrt/files/etc/config

cat << EOF > /home/build/immortalwrt/files/etc/config/pppoe-settings
enable_pppoe=${ENABLE_PPPOE}
pppoe_account=${PPPOE_ACCOUNT}
pppoe_password=${PPPOE_PASSWORD}
EOF

# 清空所有第三方包
CUSTOM_PACKAGES=""

# ==========================
# 只装 Nikki
# ==========================
PACKAGES=""
PACKAGES="$PACKAGES curl"
PACKAGES="$PACKAGES luci-i18n-base-zh-cn"

PACKAGES="$PACKAGES nikki"
PACKAGES="$PACKAGES luci-app-nikki"
PACKAGES="$PACKAGES luci-i18n-nikki-zh-cn"

echo "使用包:"
echo "$PACKAGES"

make image PROFILE="generic" \
PACKAGES="$PACKAGES" \
FILES="/home/build/immortalwrt/files" \
ROOTFS_PARTSIZE=$PROFILE

if [ $? -ne 0 ]; then
  echo "编译失败"
  exit 1
fi

echo "编译完成 (仅Nikki)"
