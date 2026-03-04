# 🍎 Mac 主机快速部署指南

## 🎯 一分钟快速开始

### 场景 1：部署到另一台 Mac（最简单）

```bash
# 1️⃣ 本地构建打包（你的开发机）
cd /Users/lujing/IdeaProjects/openclaw
./deploy/build-mac-package.sh

# 2️⃣ 部署到远程 Mac
./deploy/deploy-to-mac.sh lujing@10.36.224.143

# 3️⃣ 远程 Mac 配置（SSH 登录后）
cd ~/openclaw
node openclaw.mjs onboard --install-daemon
```

完成！✨

---

### 场景 2：使用 Git 同步（适合开发）

```bash
# 1️⃣ 远程 Mac 克隆仓库
ssh admin@remote-mac
git clone https://github.com/yourusername/openclaw.git
cd openclaw

# 2️⃣ 构建和启动
pnpm install
pnpm build
pnpm ui:build
pnpm openclaw onboard --install-daemon

# 3️⃣ 以后更新只需
cd ~/openclaw
git pull
pnpm build
pnpm ui:build
pnpm openclaw gateway restart
```

---

## 📋 两种方案对比

| 方案         | 本地操作 | 远程操作        | 更新方式            | 适用场景    |
| ------------ | -------- | --------------- | ------------------- | ----------- |
| **打包分发** | 构建打包 | 一键部署        | 重新打包部署        | 📦 生产环境 |
| **Git 同步** | Git push | Git pull + 构建 | `git pull && build` | 🔧 开发测试 |

---

## 🚀 完整工作流示例

### 示例：部署到 3 台 Mac

**主机列表：**

- Mac1: admin@192.168.1.100（办公室）
- Mac2: admin@192.168.1.101（家里）
- Mac3: admin@mac-mini.local（服务器）

#### 方法 A：使用打包部署

```bash
# 1. 本地构建一次
cd /Users/lujing/IdeaProjects/openclaw
./deploy/build-mac-package.sh

# 2. 部署到所有主机
./deploy/deploy-to-mac.sh admin@192.168.1.100
./deploy/deploy-to-mac.sh admin@192.168.1.101
./deploy/deploy-to-mac.sh admin@mac-mini.local

# 3. 每台主机配置（只需首次）
# SSH 到每台主机，运行：
cd ~/openclaw
node openclaw.mjs onboard --install-daemon
```

#### 方法 B：使用 Git 同步

```bash
# 1. 本地推送代码
git commit -am "feat: 新功能"
git push origin main

# 2. 每台远程主机更新
ssh admin@192.168.1.100 "cd ~/openclaw && git pull && pnpm build && launchctl restart ai.openclaw.gateway"
ssh admin@192.168.1.101 "cd ~/openclaw && git pull && pnpm build && launchctl restart ai.openclaw.gateway"
ssh admin@mac-mini.local "cd ~/openclaw && git pull && pnpm build && launchctl restart ai.openclaw.gateway"
```

#### 批量操作脚本

创建 `deploy/mac-hosts.txt`：

```
admin@192.168.1.100
admin@192.168.1.101
admin@mac-mini.local
```

批量更新：

```bash
#!/bin/bash
while read host; do
    echo "━━━ 更新 $host ━━━"
    ./deploy/update-mac.sh "$host"
done < deploy/mac-hosts.txt
```

---

## 💡 最佳实践

### 1. 首次部署

**准备工作：**

- [ ] 确保远程 Mac 已安装 Node.js 22+
- [ ] 配置 SSH 密钥（避免输入密码）
- [ ] 准备配置文件模板

**执行：**

```bash
# 构建
./deploy/build-mac-package.sh

# 部署
./deploy/deploy-to-mac.sh user@remote-mac

# 配置（远程主机）
ssh user@remote-mac
cd ~/openclaw
node openclaw.mjs onboard --install-daemon
```

### 2. 日常更新

**打包方式：**

```bash
# 本地
./deploy/build-mac-package.sh
./deploy/deploy-to-mac.sh user@remote-mac
```

**Git 方式：**

```bash
# 本地
git push

# 远程
ssh user@remote-mac
cd ~/openclaw && git pull && pnpm build && pnpm openclaw gateway restart
```

### 3. 配置同步

⚠️ **不要直接复制配置文件！** 敏感信息要分开管理。

**方法一：使用模板**

```bash
# 本地生成模板（自动移除敏感信息）
./deploy/sync-mac-config.sh user@remote-mac

# 远程手动配置敏感信息
ssh user@remote-mac
vim ~/.openclaw/openclaw.json
```

**方法二：环境变量**

```bash
# 远程 Mac
export TELEGRAM_BOT_TOKEN="你的token"
export ANTHROPIC_API_KEY="你的key"

# 启动时会自动读取环境变量
openclaw gateway restart
```

---

## 🔧 自动化技巧

### 1. SSH 配置简化

编辑 `~/.ssh/config`：

```
Host mac1
    HostName 192.168.1.100
    User admin
    IdentityFile ~/.ssh/id_rsa

Host mac2
    HostName 192.168.1.101
    User admin
    IdentityFile ~/.ssh/id_rsa
```

使用：

```bash
./deploy/deploy-to-mac.sh mac1
./deploy/deploy-to-mac.sh mac2
```

### 2. 一键部署脚本

创建 `quick-deploy.sh`：

```bash
#!/bin/bash
echo "🦞 快速部署 OpenClaw"

# 构建
./deploy/build-mac-package.sh

# 选择目标
echo ""
echo "选择部署目标:"
echo "1) Mac1 - 办公室 (192.168.1.100)"
echo "2) Mac2 - 家里 (192.168.1.101)"
echo "3) Mac3 - 服务器 (mac-mini.local)"
echo "4) 全部"

read -p "请选择 (1-4): " choice

case $choice in
    1) ./deploy/deploy-to-mac.sh admin@192.168.1.100 ;;
    2) ./deploy/deploy-to-mac.sh admin@192.168.1.101 ;;
    3) ./deploy/deploy-to-mac.sh admin@mac-mini.local ;;
    4)
        ./deploy/deploy-to-mac.sh admin@192.168.1.100
        ./deploy/deploy-to-mac.sh admin@192.168.1.101
        ./deploy/deploy-to-mac.sh admin@mac-mini.local
        ;;
    *) echo "无效选择" ;;
esac
```

### 3. 定时自动更新

远程 Mac 设置 cron：

```bash
# 编辑 crontab
crontab -e

# 每天凌晨 3 点自动更新（Git 方式）
0 3 * * * cd ~/openclaw && git pull && pnpm build && launchctl restart ai.openclaw.gateway > /tmp/openclaw-update.log 2>&1
```

---

## 🔍 状态检查

### 单台主机

```bash
ssh user@remote-mac << 'EOF'
    echo "━━━ OpenClaw 状态 ━━━"

    # 版本
    if [ -f ~/openclaw/package.json ]; then
        VERSION=$(node -p "require('$HOME/openclaw/package.json').version" 2>/dev/null)
        echo "版本: ${VERSION:-未知}"
    fi

    # 守护进程
    if launchctl list | grep -q "ai.openclaw.gateway"; then
        echo "守护进程: ✅ 运行中"
    else
        echo "守护进程: ❌ 未运行"
    fi

    # 配置
    if [ -f ~/.openclaw/openclaw.json ]; then
        echo "配置文件: ✅ 存在"
    else
        echo "配置文件: ❌ 缺失"
    fi

    # 最近日志
    if [ -f ~/.openclaw/logs/gateway.log ]; then
        echo ""
        echo "━━━ 最近日志 ━━━"
        tail -5 ~/.openclaw/logs/gateway.log
    fi
EOF
```

### 批量检查

```bash
# 创建 check-all.sh
for host in admin@192.168.1.100 admin@192.168.1.101; do
    echo "━━━━━━ $host ━━━━━━"
    ssh $host "launchctl list | grep openclaw || echo '未运行'"
done
```

---

## 🛠️ 故障排查

### 部署失败

**SSH 连接失败：**

```bash
# 测试连接
ssh -v user@remote-mac

# 配置密钥
ssh-copy-id user@remote-mac
```

**依赖安装失败：**

```bash
# 远程主机清理重试
ssh user@remote-mac
cd ~/openclaw
rm -rf node_modules
pnpm install --frozen-lockfile
```

**构建失败：**

```bash
# 检查 Node.js 版本
node -v  # 需要 22+

# 清理缓存
pnpm store prune
rm -rf dist/ ui/dist/
pnpm build
```

### 服务无法启动

```bash
# 查看错误日志
tail -50 ~/.openclaw/logs/gateway.err.log

# 重新安装守护进程
cd ~/openclaw
node openclaw.mjs gateway uninstall-daemon
node openclaw.mjs gateway install-daemon

# 手动启动测试
node openclaw.mjs gateway --verbose
```

### 配置问题

```bash
# 验证配置
node openclaw.mjs doctor

# 查看配置
cat ~/.openclaw/openclaw.json | jq .

# 重置配置
mv ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.backup
node openclaw.mjs onboard
```

---

## 📊 性能优化

### 加速构建

**使用 Bun（可选）：**

```bash
# 安装 Bun
curl -fsSL https://bun.sh/install | bash

# 使用 Bun 构建
bun run build
```

**并行构建：**

```bash
# 同时构建主程序和 UI
pnpm build & pnpm ui:build & wait
```

### 减小包体积

**排除不必要的文件：**

```bash
# 编辑 .npmignore 或 .gitignore
apps/
test/
docs/
*.test.ts
*.spec.ts
```

---

## ✅ 完整检查清单

### 部署前

- [ ] 远程 Mac 已安装 Node.js 22+
- [ ] 远程 Mac 已安装 pnpm
- [ ] 已配置 SSH 密钥认证
- [ ] 本地项目可以正常构建
- [ ] 已准备配置文件

### 部署中

- [ ] 成功上传部署包
- [ ] 依赖安装完成
- [ ] 配置文件已创建
- [ ] 守护进程已安装

### 部署后

- [ ] 服务正常运行
- [ ] 可以访问 Web 界面
- [ ] Telegram Bot 可以连接
- [ ] 日志无错误
- [ ] 测试发送消息

---

## 🎓 进阶技巧

### 1. 版本回滚

```bash
# 远程主机有自动备份
ls -l ~/openclaw.backup.*

# 回滚到上一版本
mv ~/openclaw ~/openclaw.failed
mv ~/openclaw.backup.20260210120000 ~/openclaw
launchctl restart ai.openclaw.gateway
```

### 2. A/B 测试

```bash
# 保留两个版本
~/openclaw-stable  # 稳定版
~/openclaw-beta    # 测试版

# 切换版本
ln -sf ~/openclaw-stable ~/openclaw-current
node ~/openclaw-current/openclaw.mjs gateway restart
```

### 3. 多环境配置

```bash
# 不同环境使用不同配置
~/.openclaw/openclaw.dev.json
~/.openclaw/openclaw.prod.json

# 启动时指定配置
OPENCLAW_CONFIG=~/.openclaw/openclaw.prod.json node openclaw.mjs gateway
```

---

现在你有了完整的 Mac 原生部署方案！🎉

**核心优势：**

- ✅ 无需 Docker
- ✅ 构建一次，到处部署
- ✅ 完整的自动化脚本
- ✅ 支持批量管理
- ✅ 可以快速回滚

**推荐工作流：**

1. 开发机：修改代码 → 构建打包
2. 远程 Mac：一键部署 → 自动重启
3. 批量更新：一个脚本搞定所有主机
