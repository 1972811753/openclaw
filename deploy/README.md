# 🍎 OpenClaw Mac 多主机部署

简单、快速、实用的 Mac 部署方案。

---

## 🚀 三步部署

### 1. 本地构建打包

```bash
cd /Users/lujing/IdeaProjects/openclaw
./deploy/build-mac-package.sh
```

### 2. 部署到远程 Mac

```bash
./deploy/deploy-to-mac.sh user@remote-mac
```

### 3. 远程配置（首次需要）

```bash
ssh user@remote-mac
cd ~/openclaw
node openclaw.mjs onboard --install-daemon
```

完成！🎉

---

## 📝 日常更新

```bash
# 重新构建
./deploy/build-mac-package.sh

# 重新部署（会自动备份旧版本）
./deploy/deploy-to-mac.sh user@remote-mac
```

---

## 📦 批量部署

### 1. 创建主机列表

```bash
cat > deploy/hosts.txt << EOF
admin@mac1.local
admin@mac2.local
developer@192.168.1.100
EOF
```

### 2. 批量部署

```bash
# 先构建一次
./deploy/build-mac-package.sh

# 批量部署
while read host; do
    echo "━━━ 部署到 $host ━━━"
    ./deploy/deploy-to-mac.sh "$host"
done < deploy/hosts.txt
```

### 3. 批量更新

```bash
while read host; do
    ./deploy/update-mac.sh "$host"
done < deploy/hosts.txt
```

---

## 🔧 配置同步（可选）

如果想同步配置到多台 Mac（会自动移除敏感信息）：

```bash
# 生成配置模板
./deploy/sync-config.sh --generate

# 部署到远程主机
./deploy/sync-config.sh --deploy
```

**注意**：需要在远程主机手动配置敏感信息（Bot Token、API Keys）。

---

## ⚡ 常用命令

### SSH 简化配置

编辑 `~/.ssh/config`：

```
Host mac1
    HostName 192.168.1.100
    User admin

Host mac2
    HostName 192.168.1.101
    User admin
```

然后直接用：

```bash
./deploy/deploy-to-mac.sh mac1
./deploy/deploy-to-mac.sh mac2
```

### 检查远程状态

```bash
ssh user@remote-mac "launchctl list | grep openclaw"
```

### 查看远程日志

```bash
ssh user@remote-mac "tail -50 ~/.openclaw/logs/gateway.log"
```

### 重启远程服务

```bash
ssh user@remote-mac "launchctl restart ai.openclaw.gateway"
```

---

## 🛠️ 故障排查

### SSH 连接失败

```bash
# 配置密钥
ssh-copy-id user@remote-mac

# 测试连接
ssh user@remote-mac "echo 'Connected!'"
```

### 服务无法启动

```bash
# 查看错误日志
ssh user@remote-mac "tail -50 ~/.openclaw/logs/gateway.err.log"

# 手动测试
ssh user@remote-mac "cd ~/openclaw && node openclaw.mjs gateway --verbose"
```

### 依赖安装失败

```bash
ssh user@remote-mac "cd ~/openclaw && rm -rf node_modules && pnpm install"
```

---

## 📊 工作流示例

### 场景：管理 3 台 Mac

```bash
# 开发机修改代码
vim src/some-file.ts
git commit -am "fix: 修复问题"

# 构建
./deploy/build-mac-package.sh

# 部署到所有 Mac
./deploy/deploy-to-mac.sh admin@office-mac
./deploy/deploy-to-mac.sh admin@home-mac
./deploy/deploy-to-mac.sh admin@server-mac

# 完成！
```

---

## 📋 检查清单

### 部署前

- [ ] 远程 Mac 已安装 Node.js 22+
- [ ] 远程 Mac 已安装 pnpm
- [ ] 已配置 SSH 密钥
- [ ] 本地可以正常构建

### 部署后

- [ ] 服务正常运行（`launchctl list | grep openclaw`）
- [ ] 配置文件存在（`~/.openclaw/openclaw.json`）
- [ ] 日志无错误（`~/.openclaw/logs/gateway.log`）
- [ ] 可以访问 Web 界面（`http://IP:18789`）

---

## 📁 文件说明

```
deploy/
├── README.md                  # 本文件（入口文档）
├── build-mac-package.sh       # 构建打包脚本
├── deploy-to-mac.sh           # 部署到远程 Mac
├── update-mac.sh              # 快速更新远程 Mac
├── sync-config.sh             # 配置同步工具（可选）
└── mac-deploy.md              # 详细文档（高级用法）
```

---

## 💡 提示

- 部署脚本会自动备份旧版本到 `~/openclaw.backup.*`
- 最多保留最近 3 个备份
- 配置文件不会被覆盖，只在首次部署时需要配置
- 可以随时回滚：`mv ~/openclaw.backup.* ~/openclaw`

---

**就这么简单！有问题查看 [mac-deploy.md](./mac-deploy.md) 了解更多。**
