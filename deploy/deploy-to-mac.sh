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

    # 加载环境变量
    if [ -f ~/.zshrc ]; then
        source ~/.zshrc 2>/dev/null || true
    fi
    if [ -f ~/.bash_profile ]; then
        source ~/.bash_profile 2>/dev/null || true
    fi
    if [ -f ~/.bashrc ]; then
        source ~/.bashrc 2>/dev/null || true
    fi

    # 常见的 Node.js 安装路径
    export PATH="$HOME/.nvm/versions/node/$(ls -t ~/.nvm/versions/node 2>/dev/null | head -1)/bin:$PATH"
    export PATH="/usr/local/bin:$PATH"
    export PATH="/opt/homebrew/bin:$PATH"
    export PATH="$HOME/.local/bin:$PATH"

    # 检查 Node.js
    if ! command -v node &> /dev/null; then
        echo "❌ Node.js 未找到"
        echo ""
        echo "当前 PATH: $PATH"
        echo ""
        echo "请检查 Node.js 安装位置:"
        echo "  which node"
        echo "  node -v"
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
    echo "   ✅ 目录创建: ~/openclaw-new"

    echo ""
    echo "📦 解压部署包..."
    PACKAGE_SIZE=$(du -h ~/openclaw-package.tar.gz | cut -f1)
    echo "   包大小: ${PACKAGE_SIZE}"
    echo "   解压中..."
    tar -xzf ~/openclaw-package.tar.gz
    echo "   ✅ 解压完成"

    echo ""
    echo "🔍 检查解压后的文件..."
    if [ ! -f openclaw.mjs ]; then
        echo "   ❌ 找不到 openclaw.mjs"
        echo "   📂 当前目录内容:"
        ls -la | head -20
        exit 1
    fi
    echo "   ✅ openclaw.mjs 存在"

    if [ ! -f package.json ]; then
        echo "   ❌ 找不到 package.json"
        exit 1
    fi
    echo "   ✅ package.json 存在"

    if [ ! -d dist ]; then
        echo "   ❌ 找不到 dist 目录"
        exit 1
    fi
    DIST_SIZE=$(du -sh dist | cut -f1)
    echo "   ✅ dist 目录存在 (${DIST_SIZE})"

    # 复用旧版本 node_modules（mv 而非 cp，避免磁盘 I/O 膨胀）
    # 只有 package.json 的 dependencies 字段没有变化时才可以跳过 install；
    # 有变化时仍然复用目录，让 npm 只增量处理 diff 的包（利用本地缓存加速）。
    _pkg_hash() {
        node -e "
            const fs=require('fs');
            const p=JSON.parse(fs.readFileSync('$1','utf8'));
            const deps=Object.assign({},p.dependencies,p.optionalDependencies);
            process.stdout.write(JSON.stringify(deps));
        " 2>/dev/null | node -e "
            const crypto=require('crypto');
            let d='';process.stdin.on('data',c=>d+=c);
            process.stdin.on('end',()=>process.stdout.write(crypto.createHash('sha1').update(d).digest('hex')));
        " 2>/dev/null
    }

    NEW_PKG_HASH=$(_pkg_hash package.json)
    OLD_PKG_HASH=""
    if [ -f ~/openclaw/package.json ]; then
        OLD_PKG_HASH=$(_pkg_hash ~/openclaw/package.json)
    fi

    DEPS_CHANGED=true
    if [ -n "$NEW_PKG_HASH" ] && [ "$NEW_PKG_HASH" = "$OLD_PKG_HASH" ] && [ -d ~/openclaw/node_modules ]; then
        DEPS_CHANGED=false
    fi

    if [ -d ~/openclaw/node_modules ]; then
        echo ""
        echo "♻️  迁移旧版本 node_modules（mv）..."
        mv ~/openclaw/node_modules ./node_modules
        echo "   ✅ 根 node_modules 已迁移"
    fi
    for ext_pkg in extensions/*/package.json; do
        ext_name=$(basename $(dirname "$ext_pkg"))
        old_ext_nm=~/openclaw/extensions/${ext_name}/node_modules
        if [ -d "$old_ext_nm" ]; then
            mv "$old_ext_nm" "extensions/${ext_name}/node_modules"
            echo "   ✅ ${ext_name} node_modules 已迁移"
        fi
    done

    if [ "$DEPS_CHANGED" = false ]; then
        echo ""
        echo "✅ package.json 依赖未变化，跳过 install"
    else
        echo ""
        echo "📥 安装/更新依赖（增量，优先本地缓存）..."
        NPM_OUTPUT=$(npm install --production --no-audit --no-fund --prefer-offline 2>&1)
        NPM_EXIT=$?
        echo "$NPM_OUTPUT" | grep -E "added|removed|changed|warn|error" || true
        if [ $NPM_EXIT -ne 0 ]; then
            echo "   ❌ 依赖安装失败"
            echo "$NPM_OUTPUT" | tail -20
            exit 1
        fi
        echo "   ✅ 依赖安装完成"

        # 安装各 extension 的独有依赖
        echo ""
        echo "📥 安装 extensions 依赖..."
        EXT_INSTALL_COUNT=0
        ROOT_DIR=$(pwd)
        for ext_pkg in extensions/*/package.json; do
            ext_dir=$(dirname "$ext_pkg")
            ext_name=$(basename "$ext_dir")
            has_deps=$(node -e "
                try {
                    const p=require('${ROOT_DIR}/${ext_pkg}');
                    const deps=Object.keys(p.dependencies||{});
                    const missing=deps.filter(d=>{
                        try{require.resolve(d,{paths:['${ROOT_DIR}']});return false;}catch{return true;}
                    });
                    console.log(missing.length > 0 ? 'yes' : 'no');
                } catch(e){ console.log('no'); }
            " 2>/dev/null)
            if [ "$has_deps" = "yes" ]; then
                echo "   安装 $ext_name 依赖..."
                (cd "$ext_dir" && npm install --production --no-audit --no-fund --prefer-offline 2>&1 | tail -1)
                EXT_INSTALL_COUNT=$((EXT_INSTALL_COUNT + 1))
            fi
        done
        if [ "$EXT_INSTALL_COUNT" -eq 0 ]; then
            echo "   ✅ 所有 extension 依赖已满足"
        else
            echo "   ✅ 已为 ${EXT_INSTALL_COUNT} 个 extension 安装独有依赖"
        fi
    fi

    echo ""
    echo "📊 依赖统计:"
    if [ -d node_modules ]; then
        MODULE_COUNT=$(find node_modules -maxdepth 1 -type d | wc -l | tr -d ' ')
        MODULE_SIZE=$(du -sh node_modules | cut -f1)
        echo "   模块数量: $((MODULE_COUNT - 1))"
        echo "   占用空间: ${MODULE_SIZE}"
    fi

    # 备份旧版本
    echo ""
    if [ -d ~/openclaw ]; then
        BACKUP_NAME="openclaw.backup.$(date +%Y%m%d%H%M%S)"
        echo "💾 备份旧版本..."
        echo "   旧版本: ~/openclaw"
        echo "   备份到: ~/${BACKUP_NAME}"
        mv ~/openclaw ~/"${BACKUP_NAME}"
        echo "   ✅ 备份完成"

        # 只保留最近 3 个备份
        OLD_BACKUPS=$(ls -dt ~/openclaw.backup.* 2>/dev/null | tail -n +4)
        if [ -n "$OLD_BACKUPS" ]; then
            echo "   🗑️  清理旧备份..."
            echo "$OLD_BACKUPS" | xargs rm -rf 2>/dev/null || true
        fi
    else
        echo "ℹ️  首次部署，无需备份"
    fi

    # 替换为新版本
    echo ""
    echo "🔄 部署新版本..."
    echo "   移动: ~/openclaw-new → ~/openclaw"
    mv ~/openclaw-new ~/openclaw
    echo "   ✅ 部署完成"

    # 修复配置文件中的路径引用
    if [ -f ~/.openclaw/openclaw.json ]; then
        echo ""
        echo "🔧 修复配置文件路径..."

        # 检查是否有备份路径引用
        if grep -q "openclaw.backup" ~/.openclaw/openclaw.json; then
            echo "   发现旧备份路径引用"

            # 备份配置文件
            cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.pre-deploy

            # 替换所有备份路径为当前路径
            # 使用 sed 兼容 macOS 和 Linux
            if sed --version 2>&1 | grep -q GNU; then
                # GNU sed (Linux)
                sed -i "s|$HOME/openclaw\.backup\.[0-9]*|$HOME/openclaw|g" ~/.openclaw/openclaw.json
            else
                # BSD sed (macOS)
                sed -i '' "s|$HOME/openclaw\.backup\.[0-9]*|$HOME/openclaw|g" ~/.openclaw/openclaw.json
            fi

            echo "   ✅ 路径已更新"
            echo "   备份: ~/.openclaw/openclaw.json.pre-deploy"
        else
            echo "   ✅ 配置路径正确，无需修复"
        fi
    fi

    # 检查配置
    echo ""
    echo "⚙️  检查配置..."
    if [ ! -f ~/.openclaw/openclaw.json ]; then
        echo "   ⚠️  配置文件不存在"
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📋 下一步操作"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "请运行初始化:"
        echo "  cd ~/openclaw"
        echo "  node openclaw.mjs onboard --install-daemon"
        echo ""
    else
        echo "   ✅ 配置文件存在: ~/.openclaw/openclaw.json"

        # 修正 plist，确保 ProgramArguments 指向自建版本
        PLIST_FILE="$HOME/Library/LaunchAgents/ai.openclaw.gateway.plist"
        if [ -f "$PLIST_FILE" ]; then
            CURRENT_ENTRY=$(/usr/libexec/PlistBuddy -c "Print :ProgramArguments:1" "$PLIST_FILE" 2>/dev/null || echo "")
            EXPECTED_ENTRY="$HOME/openclaw/openclaw.mjs"
            if [ "$CURRENT_ENTRY" != "$EXPECTED_ENTRY" ]; then
                echo ""
                echo "🔧 修正守护进程入口..."
                echo "   旧入口: $CURRENT_ENTRY"
                echo "   新入口: $EXPECTED_ENTRY"
                /usr/libexec/PlistBuddy -c "Set :ProgramArguments:1 $EXPECTED_ENTRY" "$PLIST_FILE"
                # 同步更新 Comment 中的版本号
                NEW_VER=$(node -e "console.log(require('$HOME/openclaw/package.json').version)" 2>/dev/null || echo "unknown")
                /usr/libexec/PlistBuddy -c "Set :Comment OpenClaw Gateway (v${NEW_VER})" "$PLIST_FILE" 2>/dev/null || true
                /usr/libexec/PlistBuddy -c "Set :EnvironmentVariables:OPENCLAW_SERVICE_VERSION $NEW_VER" "$PLIST_FILE" 2>/dev/null || true
                echo "   ✅ 已修正"
                # plist 改了必须 unload/load 才能生效
                launchctl unload "$PLIST_FILE" 2>/dev/null || true
                launchctl load "$PLIST_FILE" 2>/dev/null || true
                echo "   ✅ 守护进程已重新加载"
            fi
        fi

        # 尝试重启服务
        if launchctl list 2>/dev/null | grep -q "ai.openclaw.gateway"; then
            echo ""
            echo "🔄 重启守护进程..."

            # 获取当前状态
            OLD_PID=$(launchctl list | grep "ai.openclaw.gateway" | awk '{print $1}')
            if [ "$OLD_PID" != "-" ]; then
                echo "   当前 PID: $OLD_PID"
            fi

            # 使用 kickstart -k 重启服务（macOS 推荐方式）
            echo "   重启服务..."
            if launchctl kickstart -k gui/$(id -u)/ai.openclaw.gateway 2>/dev/null; then
                sleep 3

                # 检查状态
                NEW_STATUS=$(launchctl list | grep "ai.openclaw.gateway" || echo "")
                if [ -n "$NEW_STATUS" ]; then
                    NEW_PID=$(echo "$NEW_STATUS" | awk '{print $1}')
                    echo "   ✅ 服务已重启"
                    if [ "$NEW_PID" != "-" ] && [ "$NEW_PID" != "$OLD_PID" ]; then
                        echo "   新 PID: $NEW_PID"
                    fi
                else
                    echo "   ⚠️  服务可能未正常启动"
                    echo "   请检查日志: tail -f ~/.openclaw/logs/gateway.log"
                fi
            else
                echo "   ⚠️  服务重启失败"
                echo "   请手动检查: launchctl list | grep openclaw"
            fi
        else
            echo "   ⚠️  守护进程未安装"
            echo ""
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "📋 下一步操作"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
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
    echo "   ✅ 清理完成"

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
    echo "  停止服务: launchctl stop ai.openclaw.gateway"
    echo "  启动服务: launchctl kickstart -k gui/$(id -u)/ai.openclaw.gateway"
    echo ""
REMOTE_SCRIPT

echo ""
echo "🎉 部署成功！"







