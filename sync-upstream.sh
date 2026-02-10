#!/bin/bash
# 同步上游 OpenClaw 更新

set -e

echo "🦞 同步上游 OpenClaw 更新"
echo ""

# 当前分支
CURRENT_BRANCH=$(git branch --show-current)

echo "📌 当前分支: ${CURRENT_BRANCH}"
echo ""

# 1. 保存本地修改
if [[ -n $(git status -s) ]]; then
    echo "💾 发现未提交的修改，自动保存..."
    git stash push -m "Auto stash before sync $(date +%Y%m%d_%H%M%S)"
    STASHED=1
else
    STASHED=0
fi

# 2. 拉取上游更新
echo "📥 拉取上游 (upstream) 更新..."
git fetch upstream

# 3. 合并更新
echo "🔄 合并上游更新到当前分支..."
git merge upstream/main --no-edit || {
    echo "❌ 合并冲突！请手动解决后运行："
    echo "   git merge --continue"
    echo "   git stash pop  # 如果需要恢复之前的修改"
    exit 1
}

# 4. 恢复本地修改
if [ $STASHED -eq 1 ]; then
    echo "📦 恢复之前的修改..."
    git stash pop || {
        echo "⚠️  恢复修改时有冲突，请手动解决"
        echo "   git stash list  # 查看暂存"
        echo "   git stash drop  # 删除暂存"
    }
fi

# 5. 推送到你的远程仓库
echo ""
read -p "是否推送到你的远程仓库 (origin)? [y/N] " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "📤 推送到你的远程仓库..."
    git push origin ${CURRENT_BRANCH}
    echo "✅ 推送完成！"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 同步完成！"
echo ""
echo "📊 最近提交："
git log --oneline --graph --decorate -5
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
