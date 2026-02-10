#!/bin/bash
# 配置文件同步脚本
# 用于在多台主机之间同步配置文件（不包含敏感信息）

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_TEMPLATE="${SCRIPT_DIR}/config-template.json"
REMOTE_HOSTS_FILE="${SCRIPT_DIR}/hosts.txt"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

usage() {
    cat << EOF
用法: $0 [选项]

选项:
    -g, --generate     从本地配置生成模板（移除敏感信息）
    -d, --deploy       部署配置到远程主机
    -h, --help         显示此帮助信息

示例:
    # 1. 生成配置模板（从 ~/.openclaw/openclaw.json）
    $0 --generate

    # 2. 部署到远程主机（从 hosts.txt 读取主机列表）
    $0 --deploy
EOF
    exit 1
}

generate_template() {
    echo -e "${GREEN}📝 生成配置模板...${NC}"

    local local_config="${HOME}/.openclaw/openclaw.json"

    if [ ! -f "${local_config}" ]; then
        echo -e "${RED}错误: 本地配置文件不存在: ${local_config}${NC}"
        exit 1
    fi

    # 使用 jq 移除敏感信息
    if command -v jq &> /dev/null; then
        jq 'del(
            .channels.telegram.botToken,
            .channels.telegram.proxy,
            .auth.profiles,
            .models.providers[].apiKey,
            .gateway.auth.token,
            .gateway.auth.password
        )' "${local_config}" > "${CONFIG_TEMPLATE}"

        echo -e "${GREEN}✅ 配置模板已生成: ${CONFIG_TEMPLATE}${NC}"
        echo -e "${YELLOW}⚠️  敏感信息已移除，请在远程主机手动配置：${NC}"
        echo "   - Telegram Bot Token"
        echo "   - AI 模型 API Key"
        echo "   - Gateway Token/Password"
    else
        echo -e "${RED}错误: 需要安装 jq 工具${NC}"
        echo "安装: brew install jq"
        exit 1
    fi
}

deploy_to_hosts() {
    echo -e "${GREEN}🚀 部署配置到远程主机...${NC}"

    if [ ! -f "${CONFIG_TEMPLATE}" ]; then
        echo -e "${RED}错误: 配置模板不存在: ${CONFIG_TEMPLATE}${NC}"
        echo "请先运行: $0 --generate"
        exit 1
    fi

    if [ ! -f "${REMOTE_HOSTS_FILE}" ]; then
        echo -e "${YELLOW}⚠️  主机列表文件不存在: ${REMOTE_HOSTS_FILE}${NC}"
        echo "创建示例文件..."
        cat > "${REMOTE_HOSTS_FILE}" << 'HOSTS'
# 远程主机列表（每行一个）
# 格式: user@host:port（端口可选，默认22）
# 示例:
# root@192.168.1.100
# admin@server.example.com:2222
HOSTS
        echo -e "${GREEN}已创建: ${REMOTE_HOSTS_FILE}${NC}"
        echo "请编辑此文件添加远程主机"
        exit 0
    fi

    # 读取主机列表
    while IFS= read -r host || [ -n "$host" ]; do
        # 跳过注释和空行
        [[ "$host" =~ ^#.*$ ]] && continue
        [[ -z "$host" ]] && continue

        echo ""
        echo -e "${GREEN}📡 部署到: ${host}${NC}"

        # 解析主机和端口
        if [[ "$host" =~ ^([^:]+):([0-9]+)$ ]]; then
            host_addr="${BASH_REMATCH[1]}"
            host_port="${BASH_REMATCH[2]}"
        else
            host_addr="${host}"
            host_port="22"
        fi

        # 上传配置文件
        scp -P "${host_port}" "${CONFIG_TEMPLATE}" "${host_addr}:~/openclaw-config-template.json"

        # 远程执行部署
        ssh -p "${host_port}" "${host_addr}" << 'ENDSSH'
            echo "创建配置目录..."
            mkdir -p ~/.openclaw

            if [ -f ~/.openclaw/openclaw.json ]; then
                echo "⚠️  备份现有配置..."
                cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.backup.$(date +%Y%m%d%H%M%S)
            fi

            echo "部署新配置..."
            mv ~/openclaw-config-template.json ~/.openclaw/openclaw.json

            echo "✅ 配置已部署到 ~/.openclaw/openclaw.json"
            echo "⚠️  请手动配置敏感信息："
            echo "   1. Telegram Bot Token"
            echo "   2. AI API Keys"
            echo "   3. Gateway Token"
ENDSSH

        echo -e "${GREEN}✅ 完成: ${host}${NC}"
    done < "${REMOTE_HOSTS_FILE}"

    echo ""
    echo -e "${GREEN}🎉 所有主机部署完成！${NC}"
}

# 解析参数
case "${1}" in
    -g|--generate)
        generate_template
        ;;
    -d|--deploy)
        deploy_to_hosts
        ;;
    -h|--help)
        usage
        ;;
    *)
        usage
        ;;
esac
