#!/bin/bash
# 设置个人 Git 仓库并保持与上游同步

set -e

echo "🦞 配置 OpenClaw 双远程仓库"
echo ""

# 1. 重命名原始远程仓库为 upstream
echo "📌 1. 重命名 origin → upstream（上游）"
git remote rename origin upstream

# 2. 添加你的远程仓库为 origin
echo "📌 2. 添加你的远程仓库（请替换 YOUR_USERNAME）"
read -p "输入你的 GitHub 用户名: " username
git remote add origin "https://github.com/${username}/openclaw.git"

# 3. 查看配置
echo ""
echo "✅ 远程仓库配置："
git remote -v

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 配置完成！"
echo ""
echo "📝 日常工作流："
echo "  1. 推送到你的仓库:    git push origin main"
echo "  2. 拉取上游更新:      git pull upstream main"
echo "  3. 同步到你的仓库:    git push origin main"
echo ""
echo "📦 首次推送（如果你的远程仓库是空的）："
echo "  git push -u origin main"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
