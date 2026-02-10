# 🍴 OpenClaw Fork 工作流

## 📋 一次性设置

### 1. 在 GitHub 上 Fork 项目

访问 https://github.com/openclaw/openclaw 点击右上角 **Fork** 按钮

### 2. 配置本地仓库

```bash
cd /Users/lujing/IdeaProjects/openclaw

# 重命名原始远程仓库
git remote rename origin upstream

# 添加你的 Fork 仓库（替换 YOUR_USERNAME）
git remote add origin https://github.com/YOUR_USERNAME/openclaw.git

# 查看配置
git remote -v
# 应该看到：
# origin    https://github.com/YOUR_USERNAME/openclaw.git (fetch)
# origin    https://github.com/YOUR_USERNAME/openclaw.git (push)
# upstream  https://github.com/openclaw/openclaw.git (fetch)
# upstream  https://github.com/openclaw/openclaw.git (push)
```

### 3. 首次推送到你的仓库

```bash
git push -u origin main
```

---

## 🔄 日常工作流

### 提交你的修改

```bash
# 1. 修改代码后提交
git add .
git commit -m "feat: 你的修改说明"

# 2. 推送到你的仓库
git push origin main
```

### 拉取上游更新

```bash
# 方式一：使用脚本（推荐）
./sync-upstream.sh

# 方式二：手动执行
git fetch upstream
git merge upstream/main
git push origin main
```

### 处理冲突

如果合并时有冲突：

```bash
# 1. 查看冲突文件
git status

# 2. 编辑冲突文件，解决冲突

# 3. 标记为已解决
git add <冲突文件>

# 4. 完成合并
git merge --continue

# 5. 推送到你的仓库
git push origin main
```

---

## 🚀 完整示例工作流

### 场景 1：你修改了代码，想保存

```bash
# 本地修改
vim ui/src/ui/views/chat.ts

# 提交修改
git add ui/src/ui/views/chat.ts
git commit -m "feat: 优化聊天界面"

# 推送到你的仓库
git push origin main
```

### 场景 2：原项目有更新，你想同步

```bash
# 使用脚本（会自动保存你的未提交修改）
./sync-upstream.sh

# 或手动操作
git fetch upstream
git merge upstream/main
git push origin main
```

### 场景 3：同时修改+同步

```bash
# 1. 先同步上游更新
./sync-upstream.sh

# 2. 在最新代码基础上修改
vim src/some-file.ts

# 3. 提交并推送
git add .
git commit -m "feat: 新功能"
git push origin main
```

---

## 🔍 常用命令

### 查看远程仓库

```bash
git remote -v
```

### 查看分支状态

```bash
git status
git log --oneline --graph --decorate -10
```

### 查看上游更新（不合并）

```bash
git fetch upstream
git log upstream/main ^main --oneline
```

### 强制同步上游（⚠️ 会丢弃你的修改）

```bash
git fetch upstream
git reset --hard upstream/main
git push origin main --force
```

### 创建功能分支

```bash
# 为新功能创建分支
git checkout -b feature/my-feature

# 开发并提交
git add .
git commit -m "feat: 新功能"

# 推送到你的仓库
git push origin feature/my-feature

# 合并回主分支
git checkout main
git merge feature/my-feature
git push origin main
```

---

## 📊 推荐的分支策略

```
upstream/main (上游主分支)
     ↓ (定期同步)
origin/main (你的主分支，与上游保持同步)
     ↓ (创建功能分支)
origin/feature/* (你的功能分支，用于开发新功能)
```

**工作流程：**

1. 定期从 `upstream/main` 同步到 `origin/main`
2. 从 `origin/main` 创建功能分支开发
3. 功能完成后合并回 `origin/main`
4. 如果功能足够好，可以提交 PR 到 `upstream/main`

---

## 🎯 最佳实践

### ✅ 推荐

- 定期同步上游更新（每周或每次开发前）
- 为大功能创建独立分支
- 提交信息清晰明确
- 推送前先拉取更新

### ❌ 避免

- 长期不同步上游更新
- 直接在 main 分支开发大功能
- 强制推送覆盖历史（除非你清楚后果）
- 提交敏感信息（token、密码）

---

## 🆘 故障排查

### 推送被拒绝

```bash
# 错误：Updates were rejected because the tip of your current branch is behind

# 解决：先拉取合并再推送
git pull origin main --rebase
git push origin main
```

### 不小心提交了敏感信息

```bash
# 1. 从历史中移除文件
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch path/to/secret-file" \
  --prune-empty --tag-name-filter cat -- --all

# 2. 强制推送
git push origin --force --all
git push origin --force --tags

# 3. 通知 GitHub 刷新缓存
# 联系 GitHub Support 或等待自动刷新
```

### 合并冲突太多，想重新开始

```bash
# 1. 备份你的修改
cp -r /Users/lujing/IdeaProjects/openclaw ~/openclaw-backup

# 2. 重置到上游
git fetch upstream
git reset --hard upstream/main

# 3. 从备份中恢复你需要的文件
# 手动复制需要的修改

# 4. 重新提交
git add .
git commit -m "feat: 恢复自定义修改"
git push origin main --force
```

---

## 📚 参考资料

- [GitHub Fork 工作流](https://docs.github.com/en/get-started/quickstart/fork-a-repo)
- [Git 远程仓库管理](https://git-scm.com/book/zh/v2/Git-基础-远程仓库的使用)
- [保持 Fork 同步](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/working-with-forks/syncing-a-fork)
