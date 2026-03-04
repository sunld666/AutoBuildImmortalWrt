#!/bin/bash

# Log file for debugging
LOGFILE="/tmp/uci-defaults-log.txt"
echo "Starting build-mini.sh at $(date)" >> $LOGFILE

# 清空所有第三方包，只保留 Nikki
CUSTOM_PACKAGES=""
echo "第三方软件包（已清空，只留 Nikki）: $CUSTOM_PACKAGES"

echo "Create pppoe-settings"
mkdir -p /home/build/immortalwrt/files/etc/config

# 创建pppoe配置文件
cat << EOF > /home/build/immortalwrt/files/etc/config/pppoe-settings
enable_pppoe=${ENABLE_PPPOE}
pppoe_account=${PPPOE_ACCOUNT}
pppoe_password=${PPPOE_PASSWORD}
EOF

echo "cat pppoe-settings"
cat /home/build/immortalwrt/files/etc/config/pppoe-settings

# ============= 只保留 Nikki + 基础系统 ==============
PACKAGES=""

# 基础必需（不能删）
PACKAGES="$PACKAGES curl"
PACKAGES="$PACKAGES luci-i18n-base-zh-cn"

# 只安装 Nikki（你要的唯一插件）
PACKAGES="$PACKAGES nikki"
PACKAGES="$PACKAGES luci-app-nikki"
PACKAGES="$PACKAGES luci-i18n-nikki-zh-cn"

# 关闭 Docker
INCLUDE_DOCKER=no

# 不添加任何多余插件
PACKAGES="$PACKAGES $CUSTOM_PACKAGES"

# 输出调试信息
echo "$(date '+%Y-%m-%d %H:%M:%S') - 开始构建极简固件（只带 Nikki）..."
echo "使用的软件包列表:"
echo "$PACKAGES"

# 构建镜像（极简版，无多余内容）
make image PROFILE="generic" PACKAGES="$PACKAGES" FILES="/home/build/immortalwrt/files" ROOTFS_PARTSIZE=$PROFILE

if [ $? -ne 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Error: Build failed!"
    exit 1
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') - 极简固件构建完成！"
