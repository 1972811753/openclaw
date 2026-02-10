#!/bin/bash
# 快速更新远程 Mac（使用 Git 方式）

set -e

if [ $# -lt 1 ]; then
    echo "用法: $0 <user@host>"
    echo "示例: $0 admin@192.168.1.100"
    exit 1
fi

REMOTE_HOST="$1"

echo "🦞 更新远程 Mac: ${REMOTE_HOST}"
echo ""

ssh "${REMOTE_HOST}" << 'EOF'
    set -e

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "远程主机: $(hostname)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    if [ ! -d ~/openclaw ]; then
        echo "❌ OpenClaw 未安装"
        echo "请先运行部署脚本"
        exit 1
    fi

    cd ~/openclaw

    # 检查是否是 Git 仓库
    if [ -d .git ]; then
        echo "📥 拉取最新代码..."
        git fetch --all
        git pull

        echo ""
        echo "🔨 重新构建..."

        # 检查包管理器
        if command -v pnpm &> /dev/null; then
            pnpm install --frozen-lockfile
            pnpm build
            pnpm ui:build
        else
            npm install
            npm run build
            npm run ui:build
        fi

        echo ""
        echo "🔄 重启服务..."
        if launchctl list | grep -q "ai.openclaw.gateway"; then
            launchctl stop ai.openclaw.gateway
            sleep 2
            launchctl start ai.openclaw.gateway
            echo "✅ 服务已重启"
        else
            echo "⚠️  守护进程未运行"
            node openclaw.mjs gateway restart
        fi

        echo ""
        echo "✅ 更新完成！"
    else
        echo "❌ 不是 Git 仓库"
        echo "请使用 deploy-to-mac.sh 重新部署"
        exit 1
    fi
EOF

echo ""
echo "🎉 更新成功！"
