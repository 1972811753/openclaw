# 📋 OpenClaw CLI 命令完整列表

## 🚀 核心命令

### Gateway 管理

# 启动 Gateway

node openclaw.mjs gateway start

# 停止 Gateway

node openclaw.mjs gateway stop

# 重启 Gateway

node openclaw.mjs gateway restart

# 前台运行 Gateway（测试用）

node openclaw.mjs gateway run

# 查看 Gateway 状态

node openclaw.mjs gateway status

# 健康检查

node openclaw.mjs gateway health

# 安装守护进程（macOS/Linux）

node openclaw.mjs gateway install

# 卸载守护进程

node openclaw.mjs gateway uninstall

# 发现 Gateway（Bonjour）

node openclaw.mjs gateway discover

# 探测 Gateway（可达性 + 健康检查）

node openclaw.mjs gateway probe

# 调用 Gateway 方法

node openclaw.mjs gateway call <method>

# 查看使用成本

node openclaw.mjs gateway usage-cost

# Gateway 选项

node openclaw.mjs gateway start --force # 强制启动（杀死占用端口的进程）
node openclaw.mjs gateway start --port 18789 # 指定端口
node openclaw.mjs gateway start --verbose # 详细日志
node openclaw.mjs gateway start --dev # 开发模式
node openclaw.mjs gateway run --bind lan # 绑定到 LAN
node openclaw.mjs gateway run --auth token # 使用 token 认证

### 初始化和配置

# 交互式初始化向导

node openclaw.mjs onboard

# 安装守护进程

node openclaw.mjs onboard --install-daemon

# 配置向导

node openclaw.mjs configure

# 初始化配置文件

node openclaw.mjs setup

# 打开 Dashboard

node openclaw.mjs dashboard

---

## 📱 Channel 管理

### 通用命令

# 列出所有 channels

node openclaw.mjs channels list

# 登录 channel

node openclaw.mjs channels login <channel>

# 登出 channel

node openclaw.mjs channels logout <channel>

# 查看 channel 状态

node openclaw.mjs channels status

# 健康检查

node openclaw.mjs doctor

### Telegram

# 登录 Telegram

node openclaw.mjs channels login telegram

# 查看 Telegram 状态

node openclaw.mjs channels status telegram

# 发送消息

node openclaw.mjs message send --channel telegram --target @username --message "Hello"

### WhatsApp

# 登录 WhatsApp（显示二维码）

node openclaw.mjs channels login whatsapp --verbose

# 发送消息

node openclaw.mjs message send --target +15555550123 --message "Hi"

### Discord

# 登录 Discord

node openclaw.mjs channels login discord

# 发送消息

node openclaw.mjs message send --channel discord --target channel-id --message "Hello"

---

## 🔐 配对管理

# 列出配对请求

node openclaw.mjs pairing list <channel>

# 批准配对

node openclaw.mjs pairing approve <channel> <user-id>

# 批准所有配对

node openclaw.mjs pairing approve-all <channel>

# 撤销配对

node openclaw.mjs pairing revoke <channel> <user-id>

# 列出所有设备

node openclaw.mjs devices list

---

## 🤖 Agent 管理

# 运行 agent

node openclaw.mjs agent --to <target> --message "your message"

# 发送并交付消息

node openclaw.mjs agent --to <target> --message "Run summary" --deliver

# 使用本地 agent（不通过 Gateway）

node openclaw.mjs agent --local --message "your message"

# 管理 agents

node openclaw.mjs agents list
node openclaw.mjs agents create <name>
node openclaw.mjs agents delete <name>

---

## 📝 消息管理

# 发送消息

node openclaw.mjs message send --target <target> --message "text"

# 指定 channel 发送

node openclaw.mjs message send --channel telegram --target @user --message "Hi"

# 发送并返回 JSON

node openclaw.mjs message send --target <target> --message "text" --json

# 查看会话

node openclaw.mjs sessions list

---

## ⚙️ 配置管理

# 配置向导

node openclaw.mjs config

# 获取配置

node openclaw.mjs config get <key>

# 设置配置

node openclaw.mjs config set <key> <value>

# 删除配置

node openclaw.mjs config unset <key>

# 示例：配置 Gateway 绑定

node openclaw.mjs config set gateway.bind lan
node openclaw.mjs config set gateway.port 18789

# 查看模型配置

node openclaw.mjs models list

# 查看模型状态

node openclaw.mjs models status

# 查看模型状态（JSON 格式）

node openclaw.mjs models status --json

# 管理模型认证

node openclaw.mjs models auth

# 设置默认模型

node openclaw.mjs models set <model-name>

# 设置图像模型

node openclaw.mjs models set-image <model-name>

# 管理模型别名

node openclaw.mjs models aliases list
node openclaw.mjs models aliases add <alias> <model>
node openclaw.mjs models aliases remove <alias>

# 管理模型回退列表

node openclaw.mjs models fallbacks list
node openclaw.mjs models fallbacks add <model>
node openclaw.mjs models fallbacks remove <model>

# 管理图像模型回退列表

node openclaw.mjs models image-fallbacks list
node openclaw.mjs models image-fallbacks add <model>

# 扫描 OpenRouter 免费模型

node openclaw.mjs models scan

---

## 🧩 插件管理

# 列出插件

node openclaw.mjs plugins list

# 安装插件

node openclaw.mjs plugins install <plugin-name>

# 卸载插件

node openclaw.mjs plugins uninstall <plugin-name>

# 启用插件

node openclaw.mjs plugins enable <plugin-name>

# 禁用插件

node openclaw.mjs plugins disable <plugin-name>

---

## 🎯 Skills 管理

# 列出 skills

node openclaw.mjs skills list

# 查看 skill 详情

node openclaw.mjs skills info <skill-name>

# 启用 skill

node openclaw.mjs skills enable <skill-name>

# 禁用 skill

node openclaw.mjs skills disable <skill-name>

# 扫描 skills

node openclaw.mjs skills scan

---

## 🪝 Hooks 管理

# 列出 hooks

node openclaw.mjs hooks list

# 查看 hook 详情

node openclaw.mjs hooks info <hook-name>

# 启用 hook

node openclaw.mjs hooks enable <hook-name>

# 禁用 hook

node openclaw.mjs hooks disable <hook-name>

# 测试 hook

node openclaw.mjs hooks test <hook-name>

---

## 🌐 浏览器管理

# 启动浏览器

node openclaw.mjs browser start

# 停止浏览器

node openclaw.mjs browser stop

# 查看浏览器状态

node openclaw.mjs browser status

# 打开 URL

node openclaw.mjs browser open <url>

---

## 📊 监控和日志

# 查看日志

node openclaw.mjs logs

# 实时日志

node openclaw.mjs logs --follow

# 查看最近 N 行

node openclaw.mjs logs --tail 50

# 查看健康状态

node openclaw.mjs health

# 查看状态

node openclaw.mjs status

# 查看 Gateway 信息

node openclaw.mjs gateway info

---

## 🔧 系统管理

# 健康检查

node openclaw.mjs doctor

# 重置配置（保留 CLI）

node openclaw.mjs reset

# 完全卸载

node openclaw.mjs uninstall

# 更新 CLI

node openclaw.mjs update

# 查看版本

node openclaw.mjs --version

# 查看系统事件

node openclaw.mjs system events

---

## 🔐 安全和审批

# 查看待审批的执行

node openclaw.mjs approvals list

# 批准执行

node openclaw.mjs approvals approve <id>

# 拒绝执行

node openclaw.mjs approvals reject <id>

# 安全检查

node openclaw.mjs security check

---

## 🗄️ 内存和搜索

# 搜索记忆

node openclaw.mjs memory search <query>

# 查看记忆

node openclaw.mjs memory list

# 清除记忆

node openclaw.mjs memory clear

---

## 🌐 网络和 DNS

# DNS 工具

node openclaw.mjs dns lookup <hostname>

# 查看节点

node openclaw.mjs nodes list

# 节点控制

node openclaw.mjs node start
node openclaw.mjs node stop

---

## 🔄 定时任务

# 列出定时任务

node openclaw.mjs cron list

# 添加定时任务

node openclaw.mjs cron add <schedule> <command>

# 删除定时任务

node openclaw.mjs cron remove <id>

# 启用定时任务

node openclaw.mjs cron enable <id>

# 禁用定时任务

node openclaw.mjs cron disable <id>

---

## 🔌 Webhooks

# 列出 webhooks

node openclaw.mjs webhooks list

# 添加 webhook

node openclaw.mjs webhooks add <url>

# 删除 webhook

node openclaw.mjs webhooks remove <id>

# 测试 webhook

node openclaw.mjs webhooks test <id>

---

## 🎨 终端 UI

# 启动终端 UI

node openclaw.mjs tui

# 开发模式 TUI

node openclaw.mjs tui --dev

---

## 🔧 开发者命令

# 开发模式（隔离状态）

node openclaw.mjs --dev gateway

# 使用自定义 profile

node openclaw.mjs --profile myprofile gateway

# 禁用颜色输出

node openclaw.mjs --no-color <command>

# 沙箱工具

node openclaw.mjs sandbox list
node openclaw.mjs sandbox create <name>

# 文档工具

node openclaw.mjs docs search <query>

# 目录工具

node openclaw.mjs directory list

---

## 📚 帮助和文档

# 查看主帮助

node openclaw.mjs --help

# 查看子命令帮助

node openclaw.mjs <command> --help

# 示例

node openclaw.mjs gateway --help
node openclaw.mjs channels --help
node openclaw.mjs message --help

# Shell 补全

node openclaw.mjs completion bash
node openclaw.mjs completion zsh
node openclaw.mjs completion fish

---

## 💡 常用场景示例

### 快速开始

# 1. 初始化

node openclaw.mjs onboard --install-daemon

# 2. 查看状态

node openclaw.mjs status

# 3. 打开 Dashboard

node openclaw.mjs dashboard

### Telegram 配置

# 1. 登录

node openclaw.mjs channels login telegram

# 2. 查看配对请求

node openclaw.mjs pairing list telegram

# 3. 批准配对

node openclaw.mjs pairing approve telegram <user-id>

### 发送消息

# Telegram

node openclaw.mjs message send --channel telegram --target @username --message "Hello"

# WhatsApp

node openclaw.mjs message send --target +15555550123 --message "Hi"

# Discord

node openclaw.mjs message send --channel discord --target channel-id --message "Hello"

### 故障排查

# 1. 健康检查

node openclaw.mjs doctor

# 2. 查看日志

node openclaw.mjs logs --tail 50

# 3. 查看状态

node openclaw.mjs health

# 4. 重启 Gateway

launchctl kickstart -k gui/$(id -u)/ai.openclaw.gateway

---

## 🎯 最常用的命令

| 命令                                                      | 用途                             |
| --------------------------------------------------------- | -------------------------------- |
| `node openclaw.mjs gateway start`                         | 启动 Gateway                     |
| `node openclaw.mjs gateway stop`                          | 停止 Gateway                     |
| `node openclaw.mjs gateway restart`                       | 重启 Gateway                     |
| `node openclaw.mjs dashboard`                             | 打开 Dashboard（获取 token URL） |
| `node openclaw.mjs status`                                | 查看状态                         |
| `node openclaw.mjs logs`                                  | 查看日志                         |
| `node openclaw.mjs pairing list telegram`                 | 查看 Telegram 配对请求           |
| `node openclaw.mjs pairing approve telegram <id>`         | 批准 Telegram 配对               |
| `node openclaw.mjs doctor`                                | 健康检查                         |
| `node openclaw.mjs models list`                           | 查看模型配置                     |
| `node openclaw.mjs agents list`                           | 查看 agents 列表                 |
| `launchctl kickstart -k gui/$(id -u)/ai.openclaw.gateway` | 重启守护进程（macOS）            |

---

## 🎨 OpenClaw 幽默标语

OpenClaw 每次运行都会显示不同的幽默标语，例如：

- "I'll do the boring stuff while you dramatically stare at the logs like it's cinema."
- "Your inbox, your infra, your rules."
- "The only bot that stays out of your training set."
- "I can't fix your code taste, but I can fix your build and your backlog."
- "Greetings, Professor Falken"（《战争游戏》电影梗）
- "I'm like tmux: confusing at first, then suddenly you can't live without me."
- "I don't judge, but your missing API keys are absolutely judging you."

**这些标语不影响功能，纯粹是为了让命令行更有趣！** 😊

---

## 🔗 SSH 隧道（远程访问）

### 连接到远程 Gateway

```bash
# 启动 SSH 隧道（在本地运行）
ssh -f -N -L 18789:localhost:18789 lujing@10.36.224.143

# 验证隧道
lsof -i :18789

# 访问 Dashboard
open http://localhost:18789
```

### 管理隧道

```bash
# 查看隧道状态
lsof -i :18789
ps aux | grep "ssh.*18789"

# 关闭隧道
pkill -f "ssh.*18789"

# 测试连接
curl http://localhost:18789
```

### 快捷命令（可选）

添加到 `~/.zshrc` 或 `~/.bashrc`：

```bash
# OpenClaw 快捷命令
alias openclaw-connect='ssh -f -N -L 18789:localhost:18789 lujing@192.168.2.219 && echo "✅ 隧道已启动" && open http://localhost:18789'
alias openclaw-disconnect='pkill -f "ssh.*18789" && echo "✅ 隧道已关闭"'
alias openclaw-status='lsof -i :18789'
```

使用：

```bash
openclaw-connect      # 连接并打开浏览器
openclaw-disconnect   # 断开连接
openclaw-status       # 查看状态
```

---

## 🍎 macOS launchctl 命令

### 重启守护进程

```bash
# ✅ 推荐方式
launchctl kickstart -k gui/$(id -u)/ai.openclaw.gateway

# ⚠️ 或手动停止和启动
launchctl stop ai.openclaw.gateway
sleep 2
launchctl start ai.openclaw.gateway
```

### 查看服务状态

```bash
# 列出服务
launchctl list | grep openclaw

# 输出示例：
# 7987  0   ai.openclaw.gateway  ← 正常运行
# -     0   ai.openclaw.gateway  ← 已停止
# -     -15 ai.openclaw.gateway  ← 被 SIGTERM 杀死
# -     -9  ai.openclaw.gateway  ← 被 SIGKILL 强制杀死

# 查看详细信息
launchctl print gui/$(id -u)/ai.openclaw.gateway
```

### 启动/停止服务

```bash
# 启动
launchctl start ai.openclaw.gateway

# 停止
launchctl stop ai.openclaw.gateway

# 强制启动
launchctl kickstart gui/$(id -u)/ai.openclaw.gateway
```

### 加载/卸载服务

```bash
# 卸载
launchctl bootout gui/$(id -u)/ai.openclaw.gateway

# 重新加载
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/ai.openclaw.gateway.plist

# 旧方式（仍然可用）
launchctl unload ~/Library/LaunchAgents/ai.openclaw.gateway.plist
launchctl load ~/Library/LaunchAgents/ai.openclaw.gateway.plist
```

### 启用/禁用自动启动

```bash
# 禁用自动启动
launchctl disable gui/$(id -u)/ai.openclaw.gateway

# 启用自动启动
launchctl enable gui/$(id -u)/ai.openclaw.gateway

# 查看禁用的服务
launchctl print-disabled gui/$(id -u)
```

**注意：macOS 没有 `launchctl restart` 命令！**

---

## 🧹 进程管理

### 查看所有 OpenClaw 进程

```bash
# 本地
ps aux | grep -E "openclaw|18789|19001" | grep -v grep

# 远程
ssh lujing@192.168.2.219 "ps aux | grep -E 'openclaw|18789' | grep -v grep"
```

### 清理进程

```bash
# 停止本地 Gateway
pkill -f "openclaw.*gateway"
pkill -f "node.*18789"

# 关闭 SSH 隧道
pkill -f "ssh.*18789"

# 停止远程 Gateway
ssh lujing@192.168.2.219 "launchctl stop ai.openclaw.gateway"
```

### 检查端口占用

```bash
# 检查特定端口
lsof -i :18789
lsof -i :19001

# 检查所有监听端口
lsof -i -P | grep LISTEN | grep node
```

---

**提示：所有命令都可以加 `--help` 查看详细帮助！** 📖

```bash
node openclaw.mjs <command> --help
```

---

## 💼 实际使用场景

### 场景 1：本地开发 + 远程生产

**本地开发（不占用 18789 端口）：**

```bash
# 使用 dev 模式（端口 19001，独立配置）
cd /Users/lujing/IdeaProjects/openclaw
pnpm run openclaw --dev gateway start

# 或跳过 channels
OPENCLAW_SKIP_CHANNELS=1 pnpm gateway:dev
```

**访问远程生产环境：**

```bash
# 启动 SSH 隧道
ssh -f -N -L 18789:localhost:18789 lujing@192.168.2.219

# 访问
open http://localhost:18789
```

**优点**：

- ✅ 本地开发：端口 19001，独立配置
- ✅ 远程生产：端口 18789，通过隧道访问
- ✅ 互不干扰

---

### 场景 2：只使用远程 Gateway

**日常使用：**

```bash
# 早上开始工作
openclaw-connect

# 使用 UI 或 Telegram
# ...

# 晚上下班
openclaw-disconnect
```

**远程 Gateway 一直运行（供 Telegram 等使用）**

---

### 场景 3：多个 Telegram Bot

**本地测试 Bot：**

```bash
cd ~/openclaw
node openclaw.mjs onboard --profile test
# 配置测试 Bot Token

# 启动
node openclaw.mjs --profile test gateway start
```

**远程生产 Bot：**

```bash
ssh lujing@192.168.2.219
# 使用默认配置（生产 Bot）
launchctl list | grep openclaw
```

---

## 🔍 故障排查流程

### 1. UI 显示 "Gateway 离线"

```bash
# 检查远程 Gateway
ssh lujing@192.168.2.219 "launchctl list | grep openclaw"

# 检查本地隧道
lsof -i :18789

# 启动隧道（如果没有）
ssh -f -N -L 18789:localhost:18789 lujing@192.168.2.219

# 获取 token
ssh lujing@192.168.2.219 "cd ~/openclaw && node openclaw.mjs dashboard"
```

### 2. Telegram 配对失败

```bash
# 查看配对请求
ssh lujing@192.168.2.219 "cd ~/openclaw && node openclaw.mjs pairing list telegram"

# 批准配对
ssh lujing@192.168.2.219 "cd ~/openclaw && node openclaw.mjs pairing approve telegram <user-id>"
```

### 3. Gateway 启动失败

```bash
# 查看日志
ssh lujing@192.168.2.219 "tail -50 ~/.openclaw/logs/gateway.log"

# 手动测试
ssh lujing@192.168.2.219 "cd ~/openclaw && node openclaw.mjs gateway run"

# 检查配置
ssh lujing@192.168.2.219 "cat ~/.openclaw/openclaw.json | grep -A 10 gateway"
```

### 4. 端口被占用

```bash
# 检查端口
lsof -i :18789

# 清理进程
pkill -f "node.*18789"
pkill -f "ssh.*18789"
```

---

## 📚 相关文档

- `LAUNCHCTL-GUIDE.md` - macOS launchctl 完整指南
- `GATEWAY-OFFLINE-FIX.md` - Gateway 离线问题修复
- `DEPLOYMENT-GUIDE.md` - 完整部署指南
- `MAC-QUICKSTART.md` - Mac 快速开始

---

## 🎯 快速参考卡

| 操作                   | 命令                                                                                          |
| ---------------------- | --------------------------------------------------------------------------------------------- |
| **启动远程 Gateway**   | `ssh lujing@192.168.2.219 "launchctl kickstart -k gui/\$(id -u)/ai.openclaw.gateway"`         |
| **停止远程 Gateway**   | `ssh lujing@192.168.2.219 "launchctl stop ai.openclaw.gateway"`                               |
| **连接到远程**         | `ssh -f -N -L 18789:localhost:18789 lujing@192.168.2.219`                                     |
| **断开连接**           | `pkill -f "ssh.*18789"`                                                                       |
| **获取 Dashboard URL** | `ssh lujing@192.168.2.219 "cd ~/openclaw && node openclaw.mjs dashboard"`                     |
| **批准 Telegram 配对** | `ssh lujing@192.168.2.219 "cd ~/openclaw && node openclaw.mjs pairing approve telegram <id>"` |
| **查看远程日志**       | `ssh lujing@192.168.2.219 "tail -f ~/.openclaw/logs/gateway.log"`                             |
| **本地开发**           | `OPENCLAW_SKIP_CHANNELS=1 pnpm gateway:dev`                                                   |
| **检查端口**           | `lsof -i :18789`                                                                              |
| **清理进程**           | `pkill -f "ssh.*18789"`                                                                       |

---
