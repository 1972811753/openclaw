#!/bin/bash
# Mac 构建打包脚本

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "${PROJECT_DIR}"

echo "🦞 OpenClaw Mac 部署包构建"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 获取版本号
VERSION=$(node -p "require('./package.json').version")
PACKAGE_NAME="openclaw-${VERSION}-mac.tar.gz"

echo "📦 版本: ${VERSION}"
echo "📦 包名: ${PACKAGE_NAME}"
echo ""

# 清理旧构建
echo "🧹 清理旧构建..."
rm -rf dist/ ui/dist/

# 构建
echo "🔨 构建项目..."
pnpm build
pnpm ui:build

echo ""
echo "📦 打包中..."

# 打包
tar --exclude='node_modules' \
    --exclude='.git' \
    --exclude='apps' \
    --exclude='test' \
    --exclude='.idea' \
    --exclude='vendor' \
    --exclude='docs' \
    --exclude='.github' \
    -czf "${SCRIPT_DIR}/${PACKAGE_NAME}" \
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

echo ""
echo "✅ 构建完成！"
echo ""
echo "📊 包信息:"
echo "  位置: ${SCRIPT_DIR}/${PACKAGE_NAME}"
echo "  大小: $(du -h "${SCRIPT_DIR}/${PACKAGE_NAME}" | cut -f1)"
echo ""
echo "📤 部署方法:"
echo "  ./deploy/deploy-to-mac.sh user@remote-mac ${SCRIPT_DIR}/${PACKAGE_NAME}"
