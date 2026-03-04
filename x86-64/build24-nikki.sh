#!/bin/bash

source shell/custom-packages.sh
source shell/switch_repository.sh

LOGFILE="/tmp/uci-defaults-log.txt"
echo "Starting build24-nikki.sh at $(date)" >> $LOGFILE

mkdir -p /home/build/immortalwrt/files/etc/config
mkdir -p /home/build/immortalwrt/files/etc/init.d

# ==========================
# 方案2：不生成 PPPoE
# ==========================

# 清空所有第三方包
CUSTOM_PACKAGES=""

# ==========================
# 方案2 纯净包 + 完整 Nikki
# ==========================
PACKAGES=""
PACKAGES="$PACKAGES curl"
PACKAGES="$PACKAGES luci-i18n-base-zh-cn"

PACKAGES="$PACKAGES nikki"
PACKAGES="$PACKAGES luci-app-nikki"
PACKAGES="$PACKAGES luci-i18n-nikki-zh-cn"
PACKAGES="$PACKAGES nikki-data"
PACKAGES="$PACKAGES nikki-geoip"

echo "使用包:"
echo "$PACKAGES"

# ==========================
# 添加 Nikki 默认配置 & 自启
# ==========================

# 默认配置文件
cat > /home/build/immortalwrt/files/etc/config/nikki << EOF
config nikki 'main'
    option enabled '1'
    option auto_update '1'
EOF

# 确保开机自启
cat > /home/build/immortalwrt/files/etc/init.d/nikki << 'EOF'
#!/bin/sh /etc/rc.common
START=99
STOP=10

start() {
    /etc/init.d/nikki enable
    /usr/bin/nikki &
}

stop() {
    killall -q nikki
}
EOF

chmod +x /home/build/immortalwrt/files/etc/init.d/nikki

# ==========================
# 开始编译
# ==========================
make image PROFILE="generic" \
PACKAGES="$PACKAGES" \
FILES="/home/build/immortalwrt/files" \
ROOTFS_PARTSIZE=$PROFILE

if [ $? -ne 0 ]; then
  echo "编译失败"
  exit 1
fi

echo "编译完成 (方案2：纯净Nikki + 默认配置 + 自启动)"
