# 🍎 OpenClaw Mac 主机部署方案

**适用于：** 没有 Docker 的 Mac 主机，直接使用 Node.js 运行

---

## 🎯 两种部署方式

### 方案一：打包分发（推荐生产环境）

**原理**：本地构建打包，传输到远程主机

**优点**：

- ✅ 快速可靠
- ✅ 适合多台主机
- ✅ 版本统一
- ✅ 无需 Git 访问

**使用方法**：见 [README.md](./README.md)

---

### 方案二：Git 同步（推荐开发环境）

**原理**：通过 Git 同步源码，本地构建运行

#### 1. 本地推送（开发机）

```bash
cd /Users/lujing/IdeaProjects/openclaw

# 提交修改
git add .
git commit -m "feat: 新功能"
git push origin main

# 打标签（可选）
git tag v2026.2.6-4
git push --tags
```

#### 2. 远程部署（目标 Mac）

**首次部署：**

```bash
# 克隆仓库
git clone https://github.com/yourusername/openclaw.git
cd openclaw

# 安装依赖
pnpm install

# 构建
pnpm build
pnpm ui:build

# 链接到全局（可选）
pnpm link --global

# 初始化
pnpm openclaw onboard --install-daemon
```

**日常更新：**

```bash
cd ~/openclaw

# 拉取最新代码
git pull

# 重新构建
pnpm build
pnpm ui:build

# 重启服务
pnpm openclaw gateway restart
```

**优点**：

- ✅ 适合开发和测试
- ✅ 可以快速调试
- ✅ 完全控制源码

---

## 📦 详细步骤

### 使用打包分发方式

#### 1. 本地打包（开发机）

```bash
cd /Users/lujing/IdeaProjects/openclaw

# 构建
pnpm build
pnpm ui:build

# 打包（排除 node_modules）
tar --exclude='node_modules' \
    --exclude='.git' \
    --exclude='apps' \
    --exclude='test' \
    -czf openclaw-build.tar.gz \
    dist/ \
    ui/dist/ \
    package.json \
    pnpm-lock.yaml \
    openclaw.mjs \
    assets/ \
    skills/ \
    extensions/ \
    scripts/

# 查看包大小
ls -lh openclaw-build.tar.gz
```

#### 2. 传输并部署（目标 Mac）

```bash
# 从本地传输
scp openclaw-build.tar.gz user@remote-mac:~/

# SSH 到远程主机
ssh user@remote-mac

# 解压
mkdir -p ~/openclaw
cd ~/openclaw
tar -xzf ~/openclaw-build.tar.gz

# 安装依赖
pnpm install --prod

# 配置
mkdir -p ~/.openclaw
# 手动复制配置文件，或运行 onboard

# 安装守护进程
node openclaw.mjs gateway install-daemon

# 启动
launchctl start ai.openclaw.gateway
```

**优点**：

- ✅ 不需要 npm 仓库
- ✅ 不需要 Git 访问
- ✅ 适合内网环境

---

## 🚀 推荐工作流

### 场景 1：多台开发 Mac

使用 **Git 同步**：

```bash
# 主机 A（开发机）
git push

# 主机 B（其他 Mac）
git pull
pnpm build
pnpm openclaw gateway restart
```

### 场景 2：生产 Mac 服务器

使用 **npm 发布**：

```bash
# 本地
npm publish

# 远程
npm update -g openclaw
openclaw gateway restart
```

### 场景 3：内网 Mac 主机

使用 **构建包分发**：

```bash
# 本地
./deploy/build-package.sh

# 远程
./deploy/install-package.sh
```

---

## 📦 自动化脚本

### 创建打包脚本

创建 `deploy/build-mac-package.sh`：

```bash
#!/bin/bash
# Mac 构建打包脚本

set -e

cd "$(dirname "$0")/.."

echo "🦞 构建 OpenClaw Mac 部署包"

# 清理旧构建
rm -rf dist/ ui/dist/

# 构建
echo "📦 构建项目..."
pnpm build
pnpm ui:build

# 打包
VERSION=$(node -p "require('./package.json').version")
PACKAGE_NAME="openclaw-${VERSION}-mac.tar.gz"

echo "📦 打包 ${PACKAGE_NAME}..."
tar --exclude='node_modules' \
    --exclude='.git' \
    --exclude='apps' \
    --exclude='test' \
    --exclude='.idea' \
    --exclude='vendor' \
    -czf "deploy/${PACKAGE_NAME}" \
    dist/ \
    ui/dist/ \
    package.json \
    pnpm-lock.yaml \
    pnpm-workspace.yaml \
    .npmrc \
    openclaw.mjs \
    assets/ \
    skills/ \
    extensions/ \
    patches/ \
    scripts/

echo "✅ 打包完成: deploy/${PACKAGE_NAME}"
echo "📊 包大小: $(du -h "deploy/${PACKAGE_NAME}" | cut -f1)"
```

### 创建部署脚本

创建 `deploy/deploy-to-mac.sh`：

```bash
#!/bin/bash
# 部署到远程 Mac 主机

set -e

if [ $# -lt 1 ]; then
    echo "用法: $0 <user@host> [包文件]"
    echo "示例: $0 admin@192.168.1.100"
    exit 1
fi

REMOTE_HOST="$1"
PACKAGE_FILE="${2:-$(ls -t deploy/openclaw-*-mac.tar.gz 2>/dev/null | head -1)}"

if [ -z "$PACKAGE_FILE" ] || [ ! -f "$PACKAGE_FILE" ]; then
    echo "❌ 找不到部署包"
    echo "请先运行: ./deploy/build-mac-package.sh"
    exit 1
fi

echo "🦞 部署 OpenClaw 到 ${REMOTE_HOST}"
echo "📦 使用包: ${PACKAGE_FILE}"
echo ""

# 上传包
echo "📤 上传部署包..."
scp "${PACKAGE_FILE}" "${REMOTE_HOST}:~/openclaw-package.tar.gz"

# 远程部署
echo "🚀 远程部署..."
ssh "${REMOTE_HOST}" << 'EOF'
    set -e

    echo "📁 创建目录..."
    mkdir -p ~/openclaw-new
    cd ~/openclaw-new

    echo "📦 解压..."
    tar -xzf ~/openclaw-package.tar.gz

    echo "📥 安装依赖..."
    if command -v pnpm &> /dev/null; then
        pnpm install --prod --frozen-lockfile
    else
        echo "⚠️  pnpm 未安装，使用 npm"
        npm install --production
    fi

    # 备份旧版本
    if [ -d ~/openclaw ]; then
        echo "💾 备份旧版本..."
        mv ~/openclaw ~/openclaw.backup.$(date +%Y%m%d%H%M%S)
    fi

    # 替换
    echo "🔄 替换为新版本..."
    mv ~/openclaw-new ~/openclaw

    # 配置守护进程（如果需要）
    if [ ! -f ~/.openclaw/openclaw.json ]; then
        echo "⚠️  未找到配置文件"
        echo "请运行: cd ~/openclaw && node openclaw.mjs onboard --install-daemon"
    else
        echo "🔄 重启服务..."
        cd ~/openclaw

        # 尝试重启 launchd 服务
        if launchctl list | grep -q "ai.openclaw.gateway"; then
            launchctl stop ai.openclaw.gateway 2>/dev/null || true
            sleep 2
            launchctl start ai.openclaw.gateway
            echo "✅ 服务已重启"
        else
            echo "⚠️  守护进程未安装"
            echo "运行: node openclaw.mjs gateway install-daemon"
        fi
    fi

    echo ""
    echo "✅ 部署完成！"
    echo "📍 安装位置: ~/openclaw"

    # 清理
    rm -f ~/openclaw-package.tar.gz
EOF

echo ""
echo "🎉 部署成功！"
```

---

## 🔄 配置同步

### 同步配置文件到远程 Mac

创建 `deploy/sync-mac-config.sh`：

```bash
#!/bin/bash
# 同步配置到远程 Mac

if [ $# -lt 1 ]; then
    echo "用法: $0 <user@host>"
    exit 1
fi

REMOTE_HOST="$1"
LOCAL_CONFIG="${HOME}/.openclaw/openclaw.json"

if [ ! -f "${LOCAL_CONFIG}" ]; then
    echo "❌ 本地配置不存在: ${LOCAL_CONFIG}"
    exit 1
fi

echo "🦞 同步配置到 ${REMOTE_HOST}"

# 创建临时文件（移除敏感信息）
TEMP_CONFIG=$(mktemp)

# 使用 jq 清理敏感信息
if command -v jq &> /dev/null; then
    jq 'del(
        .channels.telegram.botToken,
        .auth.profiles,
        .models.providers[].apiKey,
        .gateway.auth.token
    )' "${LOCAL_CONFIG}" > "${TEMP_CONFIG}"
else
    echo "⚠️  jq 未安装，复制完整配置"
    cp "${LOCAL_CONFIG}" "${TEMP_CONFIG}"
fi

# 上传配置
scp "${TEMP_CONFIG}" "${REMOTE_HOST}:~/.openclaw/openclaw.json"

# 清理
rm -f "${TEMP_CONFIG}"

echo "✅ 配置已同步"
echo "⚠️  请在远程主机手动配置敏感信息"
```

---

## 📊 批量管理

### 管理多台 Mac

创建主机列表 `deploy/mac-hosts.txt`：

```
admin@mac1.local
admin@mac2.local
developer@192.168.1.100
```

批量部署脚本 `deploy/deploy-all-macs.sh`：

```bash
#!/bin/bash

HOSTS_FILE="deploy/mac-hosts.txt"
PACKAGE_FILE="$1"

if [ ! -f "${HOSTS_FILE}" ]; then
    echo "❌ 主机列表不存在: ${HOSTS_FILE}"
    exit 1
fi

while IFS= read -r host || [ -n "$host" ]; do
    [[ "$host" =~ ^#.*$ ]] && continue
    [[ -z "$host" ]] && continue

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📡 部署到: ${host}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    ./deploy/deploy-to-mac.sh "${host}" "${PACKAGE_FILE}"

done < "${HOSTS_FILE}"

echo ""
echo "🎉 所有主机部署完成！"
```

---

## 🔍 状态检查

批量检查状态 `deploy/check-all-macs.sh`：

```bash
#!/bin/bash

HOSTS_FILE="deploy/mac-hosts.txt"

while IFS= read -r host; do
    [[ "$host" =~ ^#.*$ ]] && continue
    [[ -z "$host" ]] && continue

    echo "━━━ ${host} ━━━"
    ssh "${host}" << 'EOF'
        # 检查服务状态
        if launchctl list | grep -q "ai.openclaw.gateway"; then
            echo "✅ 守护进程: 运行中"
        else
            echo "❌ 守护进程: 未运行"
        fi

        # 检查版本
        if [ -f ~/openclaw/package.json ]; then
            VERSION=$(node -p "require('$HOME/openclaw/package.json').version" 2>/dev/null)
            echo "📦 版本: ${VERSION:-未知}"
        fi

        # 检查配置
        if [ -f ~/.openclaw/openclaw.json ]; then
            echo "⚙️  配置: 存在"
        else
            echo "❌ 配置: 缺失"
        fi
EOF
    echo ""
done < "${HOSTS_FILE}"
```

---

## 💡 最佳实践

### 1. 版本管理

使用 Git 标签管理版本：

```bash
# 发布新版本
git tag v2026.2.6-4
git push --tags

# 远程主机切换版本
cd ~/openclaw
git fetch --tags
git checkout v2026.2.6-4
pnpm build
pnpm openclaw gateway restart
```

### 2. 配置管理

**不要直接同步完整配置！** 使用模板：

```bash
# 生成配置模板（移除敏感信息）
./deploy/sync-mac-config.sh user@remote-mac

# 远程主机手动配置敏感信息
ssh user@remote-mac
vim ~/.openclaw/openclaw.json
```

### 3. 自动更新

在远程 Mac 设置定时任务：

```bash
# 编辑 crontab
crontab -e

# 每天凌晨 3 点自动更新
0 3 * * * cd ~/openclaw && git pull && pnpm build && launchctl restart ai.openclaw.gateway
```

---

## 🛠️ 故障排查

### 守护进程无法启动

```bash
# 查看日志
tail -f ~/.openclaw/logs/gateway.log
tail -f ~/.openclaw/logs/gateway.err.log

# 重新安装守护进程
cd ~/openclaw
node openclaw.mjs gateway uninstall-daemon
node openclaw.mjs gateway install-daemon

# 手动启动测试
node openclaw.mjs gateway
```

### 依赖安装失败

```bash
# 清理缓存
rm -rf node_modules
pnpm store prune

# 重新安装
pnpm install --frozen-lockfile
```

### 端口冲突

```bash
# 检查端口占用
lsof -i :18789

# 修改配置
vim ~/.openclaw/openclaw.json
# 修改 gateway.port
```

---

## 📋 完整部署清单

### 首次部署检查

- [ ] 远程 Mac 已安装 Node.js 22+
- [ ] 远程 Mac 已安装 pnpm（或 npm）
- [ ] 已配置 SSH 密钥登录
- [ ] 已准备好配置文件模板
- [ ] 已测试本地构建成功

### 部署步骤

1. [ ] 本地构建打包或发布 npm
2. [ ] 传输到远程主机
3. [ ] 远程安装依赖
4. [ ] 配置 ~/.openclaw/openclaw.json
5. [ ] 安装守护进程
6. [ ] 启动服务
7. [ ] 验证运行状态
8. [ ] 测试 Telegram Bot 连接

---

## 🎯 推荐方案选择

| 场景         | 推荐方案   | 理由         |
| ------------ | ---------- | ------------ |
| 个人多台 Mac | Git 同步   | 方便开发调试 |
| 团队协作     | npm 发布   | 版本管理清晰 |
| 内网环境     | 构建包分发 | 无需外网访问 |
| 快速原型     | Git clone  | 最简单快速   |

---

现在你有了完整的 Mac 原生部署方案！ 🎉
