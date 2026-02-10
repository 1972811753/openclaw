#!/bin/bash
# 部署到远程 Mac 主机

set -e

if [ $# -lt 1 ]; then
    cat << 'USAGE'
用法: ./deploy-to-mac.sh <user@host> [包文件]

示例:
    ./deploy-to-mac.sh admin@192.168.1.100
    ./deploy-to-mac.sh admin@mac.local openclaw-2026.2.6-3-mac.tar.gz

说明:
    如果不指定包文件，会自动使用最新的构建包
    首次部署需要手动配置敏感信息（Bot Token、API Keys等）
USAGE
    exit 1
fi

REMOTE_HOST="$1"
PACKAGE_FILE="${2:-$(ls -t deploy/openclaw-*-mac.tar.gz 2>/dev/null | head -1)}"

if [ -z "$PACKAGE_FILE" ] || [ ! -f "$PACKAGE_FILE" ]; then
    echo "❌ 找不到部署包"
    echo ""
    echo "请先构建:"
    echo "  ./deploy/build-mac-package.sh"
    exit 1
fi

echo "🦞 OpenClaw 部署到远程 Mac"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📡 目标主机: ${REMOTE_HOST}"
echo "📦 部署包: ${PACKAGE_FILE}"
echo ""

# 检查 SSH 连接
echo "🔍 检查 SSH 连接..."
if ! ssh -o ConnectTimeout=5 "${REMOTE_HOST}" "echo '✅ 连接成功'" 2>/dev/null; then
    echo "❌ 无法连接到 ${REMOTE_HOST}"
    echo ""
    echo "请检查:"
    echo "  1. SSH 配置是否正确"
    echo "  2. 主机是否在线"
    echo "  3. 是否配置了 SSH 密钥"
    exit 1
fi

echo ""

# 上传包
echo "📤 上传部署包..."
scp "${PACKAGE_FILE}" "${REMOTE_HOST}:~/openclaw-package.tar.gz"

echo ""
echo "🚀 开始远程部署..."
echo ""

# 远程部署
ssh "${REMOTE_HOST}" << 'REMOTE_SCRIPT'
    set -e

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "远程主机: $(hostname)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # 检查 Node.js
    if ! command -v node &> /dev/null; then
        echo "❌ Node.js 未安装"
        echo "请先安装 Node.js 22+"
        exit 1
    fi

    NODE_VERSION=$(node -v)
    echo "✅ Node.js: ${NODE_VERSION}"

    # 检查包管理器
    if command -v pnpm &> /dev/null; then
        PKG_MANAGER="pnpm"
        echo "✅ 使用 pnpm"
    else
        PKG_MANAGER="npm"
        echo "⚠️  pnpm 未安装，使用 npm（推荐安装 pnpm）"
    fi

    echo ""
    echo "📁 创建临时目录..."
    mkdir -p ~/openclaw-new
    cd ~/openclaw-new

    echo "📦 解压部署包..."
    tar -xzf ~/openclaw-package.tar.gz

    echo "📥 安装依赖..."
    if [ "$PKG_MANAGER" = "pnpm" ]; then
        pnpm install --prod --frozen-lockfile 2>&1 | grep -v "Progress"
    else
        npm install --production --no-audit --no-fund
    fi

    # 备份旧版本
    if [ -d ~/openclaw ]; then
        BACKUP_NAME="openclaw.backup.$(date +%Y%m%d%H%M%S)"
        echo "💾 备份旧版本到: ~/${BACKUP_NAME}"
        mv ~/openclaw ~/"${BACKUP_NAME}"

        # 只保留最近 3 个备份
        ls -dt ~/openclaw.backup.* 2>/dev/null | tail -n +4 | xargs rm -rf 2>/dev/null || true
    fi

    # 替换为新版本
    echo "🔄 部署新版本..."
    mv ~/openclaw-new ~/openclaw

    # 检查配置
    echo ""
    if [ ! -f ~/.openclaw/openclaw.json ]; then
        echo "⚠️  配置文件不存在"
        echo ""
        echo "请运行初始化:"
        echo "  cd ~/openclaw"
        echo "  node openclaw.mjs onboard --install-daemon"
        echo ""
    else
        echo "✅ 配置文件存在"

        # 尝试重启服务
        if launchctl list 2>/dev/null | grep -q "ai.openclaw.gateway"; then
            echo ""
            echo "🔄 重启守护进程..."

            # 停止服务
            launchctl stop ai.openclaw.gateway 2>/dev/null || true
            sleep 2

            # 启动服务
            if launchctl start ai.openclaw.gateway 2>/dev/null; then
                echo "✅ 服务已重启"

                # 等待服务启动
                sleep 3

                # 检查状态
                if launchctl list | grep -q "ai.openclaw.gateway"; then
                    echo "✅ 服务运行正常"
                else
                    echo "⚠️  服务可能未正常启动，请检查日志"
                fi
            else
                echo "⚠️  服务启动失败"
                echo "请手动检查: launchctl list | grep openclaw"
            fi
        else
            echo "⚠️  守护进程未安装"
            echo ""
            echo "安装守护进程:"
            echo "  cd ~/openclaw"
            echo "  node openclaw.mjs gateway install-daemon"
        fi
    fi

    # 清理
    echo ""
    echo "🧹 清理临时文件..."
    rm -f ~/openclaw-package.tar.gz

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ 远程部署完成！"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📍 安装位置: ~/openclaw"
    echo "⚙️  配置文件: ~/.openclaw/openclaw.json"
    echo "📝 日志目录: ~/.openclaw/logs/"
    echo ""
    echo "常用命令:"
    echo "  查看状态: launchctl list | grep openclaw"
    echo "  查看日志: tail -f ~/.openclaw/logs/gateway.log"
    echo "  重启服务: launchctl restart ai.openclaw.gateway"
    echo ""
REMOTE_SCRIPT

echo ""
echo "🎉 部署成功！"
