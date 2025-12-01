#!/bin/bash

# IPTV4 项目快速部署脚本
# 用于快速部署到 Cloudflare Workers

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

# 检查命令是否存在
check_command() {
    if ! command -v $1 &> /dev/null; then
        print_error "$1 未安装"
        return 1
    fi
    return 0
}

# 检查必要的工具
check_requirements() {
    print_header "检查环境依赖"
    
    local missing_tools=()
    
    if ! check_command "git"; then
        missing_tools+=("git")
    else
        print_success "Git 已安装"
    fi
    
    if ! check_command "node"; then
        missing_tools+=("node")
    else
        print_success "Node.js 已安装 ($(node --version))"
    fi
    
    if ! check_command "npm"; then
        missing_tools+=("npm")
    else
        print_success "npm 已安装 ($(npm --version))"
    fi
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        print_error "缺少以下工具: ${missing_tools[*]}"
        print_info "请先安装这些工具后再运行此脚本"
        exit 1
    fi
    
    echo ""
}

# 检查 wrangler 是否安装
check_wrangler() {
    print_header "检查 Wrangler CLI"
    
    if ! check_command "wrangler"; then
        print_warning "Wrangler 未安装"
        read -p "是否现在安装 Wrangler? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "正在安装 Wrangler..."
            npm install -g wrangler
            print_success "Wrangler 安装完成"
        else
            print_error "需要 Wrangler 才能部署，退出"
            exit 1
        fi
    else
        print_success "Wrangler 已安装 ($(wrangler --version))"
    fi
    
    echo ""
}

# 检查 Cloudflare 登录状态
check_cloudflare_auth() {
    print_header "检查 Cloudflare 认证"
    
    if ! wrangler whoami &> /dev/null; then
        print_warning "未登录 Cloudflare"
        read -p "是否现在登录? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "正在打开浏览器进行登录..."
            wrangler login
            print_success "登录成功"
        else
            print_error "需要登录 Cloudflare 才能部署，退出"
            exit 1
        fi
    else
        print_success "已登录 Cloudflare"
        wrangler whoami
    fi
    
    echo ""
}

# 配置 GitHub 信息
configure_github() {
    print_header "配置 GitHub 信息"
    
    # 检查 worker.js 是否存在
    if [ ! -f "worker.js" ]; then
        print_error "worker.js 文件不存在"
        exit 1
    fi
    
    # 检查是否已配置
    if grep -q "YOUR_GITHUB_USERNAME" worker.js; then
        print_warning "检测到 GitHub 配置未完成"
        
        # 获取当前 Git 用户名作为默认值
        local default_username=""
        if git config user.name &> /dev/null; then
            default_username=$(git config user.name)
        fi
        
        read -p "请输入你的 GitHub 用户名 [$default_username]: " github_username
        github_username=${github_username:-$default_username}
        
        if [ -z "$github_username" ]; then
            print_error "GitHub 用户名不能为空"
            exit 1
        fi
        
        read -p "请输入仓库名 [iptv4]: " repo_name
        repo_name=${repo_name:-iptv4}
        
        read -p "请输入分支名 [main]: " branch_name
        branch_name=${branch_name:-main}
        
        # 备份原文件
        cp worker.js worker.js.backup
        
        # 替换配置
        sed -i.tmp "s/YOUR_GITHUB_USERNAME/$github_username/g" worker.js
        sed -i.tmp "s/repo: 'iptv4'/repo: '$repo_name'/g" worker.js
        sed -i.tmp "s/branch: 'main'/branch: '$branch_name'/g" worker.js
        rm -f worker.js.tmp
        
        print_success "GitHub 配置已更新"
        print_info "用户名: $github_username"
        print_info "仓库名: $repo_name"
        print_info "分支名: $branch_name"
    else
        print_success "GitHub 配置已完成"
    fi
    
    echo ""
}

# 检查 Git 仓库状态
check_git_status() {
    print_header "检查 Git 仓库状态"
    
    if [ ! -d ".git" ]; then
        print_warning "当前目录不是 Git 仓库"
        read -p "是否初始化 Git 仓库? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git init
            print_success "Git 仓库初始化完成"
        else
            print_warning "跳过 Git 初始化"
        fi
    else
        print_success "Git 仓库已存在"
    fi
    
    # 检查是否有未提交的更改
    if [ -d ".git" ]; then
        if ! git diff-index --quiet HEAD -- 2>/dev/null; then
            print_warning "检测到未提交的更改"
            read -p "是否提交更改? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                git add .
                read -p "请输入提交信息 [Update configuration]: " commit_msg
                commit_msg=${commit_msg:-"Update configuration"}
                git commit -m "$commit_msg"
                print_success "更改已提交"
                
                # 询问是否推送
                read -p "是否推送到远程仓库? (y/n) " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    git push
                    print_success "已推送到远程仓库"
                fi
            fi
        else
            print_success "没有未提交的更改"
        fi
    fi
    
    echo ""
}

# 部署到 Cloudflare Workers
deploy_worker() {
    print_header "部署到 Cloudflare Workers"
    
    print_info "正在部署..."
    
    if wrangler deploy; then
        print_success "部署成功！"
        echo ""
        print_info "你的 Worker 已部署，可以通过以下方式访问："
        echo ""
        
        # 尝试获取 Worker URL
        if wrangler deployments list 2>/dev/null | grep -q "https://"; then
            worker_url=$(wrangler deployments list 2>/dev/null | grep -oP 'https://[^\s]+' | head -1)
            print_success "Worker URL: $worker_url"
            echo ""
            print_info "测试访问："
            echo "  - 首页: $worker_url"
            echo "  - IPTV4 完整版: $worker_url/iptv4/iptv4"
            echo "  - IPTV4 精简版: $worker_url/iptv4/simple_iptv4"
        fi
    else
        print_error "部署失败"
        exit 1
    fi
    
    echo ""
}

# 显示后续步骤
show_next_steps() {
    print_header "后续步骤"
    
    echo "1. 📺 在 IPTV 播放器中添加订阅源"
    echo "2. 🔧 如需自定义域名，请访问 Cloudflare Dashboard"
    echo "3. 📝 查看 DEPLOYMENT.md 了解更多配置选项"
    echo "4. 📖 查看 ADD_SOURCE.md 了解如何添加新的直播源"
    echo ""
    print_success "部署完成！享受你的 IPTV 服务吧！"
}

# 主函数
main() {
    clear
    print_header "IPTV4 快速部署脚本"
    echo ""
    
    # 执行检查和部署步骤
    check_requirements
    check_wrangler
    check_cloudflare_auth
    configure_github
    check_git_status
    deploy_worker
    show_next_steps
}

# 运行主函数
main