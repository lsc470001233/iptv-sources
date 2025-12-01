@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: IPTV4 项目快速部署脚本 (Windows)
:: 用于快速部署到 Cloudflare Workers

title IPTV4 快速部署脚本

:: 颜色定义 (Windows 10+)
set "INFO=[94m"
set "SUCCESS=[92m"
set "WARNING=[93m"
set "ERROR=[91m"
set "RESET=[0m"

:: 打印带颜色的消息
:print_info
echo %INFO%ℹ️  %~1%RESET%
goto :eof

:print_success
echo %SUCCESS%✅ %~1%RESET%
goto :eof

:print_warning
echo %WARNING%⚠️  %~1%RESET%
goto :eof

:print_error
echo %ERROR%❌ %~1%RESET%
goto :eof

:print_header
echo.
echo %INFO%================================%RESET%
echo %INFO%%~1%RESET%
echo %INFO%================================%RESET%
echo.
goto :eof

:: 主程序开始
cls
call :print_header "IPTV4 快速部署脚本"

:: 检查 Node.js
call :print_header "检查环境依赖"

where node >nul 2>&1
if %errorlevel% neq 0 (
    call :print_error "Node.js 未安装"
    echo 请从 https://nodejs.org/ 下载并安装 Node.js
    pause
    exit /b 1
) else (
    for /f "tokens=*" %%i in ('node --version') do set NODE_VERSION=%%i
    call :print_success "Node.js 已安装 (!NODE_VERSION!)"
)

where npm >nul 2>&1
if %errorlevel% neq 0 (
    call :print_error "npm 未安装"
    pause
    exit /b 1
) else (
    for /f "tokens=*" %%i in ('npm --version') do set NPM_VERSION=%%i
    call :print_success "npm 已安装 (!NPM_VERSION!)"
)

where git >nul 2>&1
if %errorlevel% neq 0 (
    call :print_warning "Git 未安装 (可选)"
) else (
    call :print_success "Git 已安装"
)

:: 检查 Wrangler
call :print_header "检查 Wrangler CLI"

where wrangler >nul 2>&1
if %errorlevel% neq 0 (
    call :print_warning "Wrangler 未安装"
    set /p INSTALL_WRANGLER="是否现在安装 Wrangler? (y/n): "
    if /i "!INSTALL_WRANGLER!"=="y" (
        call :print_info "正在安装 Wrangler..."
        call npm install -g wrangler
        if !errorlevel! equ 0 (
            call :print_success "Wrangler 安装完成"
        ) else (
            call :print_error "Wrangler 安装失败"
            pause
            exit /b 1
        )
    ) else (
        call :print_error "需要 Wrangler 才能部署，退出"
        pause
        exit /b 1
    )
) else (
    for /f "tokens=*" %%i in ('wrangler --version') do set WRANGLER_VERSION=%%i
    call :print_success "Wrangler 已安装 (!WRANGLER_VERSION!)"
)

:: 检查 Cloudflare 登录状态
call :print_header "检查 Cloudflare 认证"

wrangler whoami >nul 2>&1
if %errorlevel% neq 0 (
    call :print_warning "未登录 Cloudflare"
    set /p DO_LOGIN="是否现在登录? (y/n): "
    if /i "!DO_LOGIN!"=="y" (
        call :print_info "正在打开浏览器进行登录..."
        call wrangler login
        if !errorlevel! equ 0 (
            call :print_success "登录成功"
        ) else (
            call :print_error "登录失败"
            pause
            exit /b 1
        )
    ) else (
        call :print_error "需要登录 Cloudflare 才能部署，退出"
        pause
        exit /b 1
    )
) else (
    call :print_success "已登录 Cloudflare"
    wrangler whoami
)

:: 配置 GitHub 信息
call :print_header "配置 GitHub 信息"

if not exist "worker.js" (
    call :print_error "worker.js 文件不存在"
    pause
    exit /b 1
)

findstr /C:"YOUR_GITHUB_USERNAME" worker.js >nul
if %errorlevel% equ 0 (
    call :print_warning "检测到 GitHub 配置未完成"
    
    set /p GITHUB_USERNAME="请输入你的 GitHub 用户名: "
    if "!GITHUB_USERNAME!"=="" (
        call :print_error "GitHub 用户名不能为空"
        pause
        exit /b 1
    )
    
    set /p REPO_NAME="请输入仓库名 [iptv4]: "
    if "!REPO_NAME!"=="" set REPO_NAME=iptv4
    
    set /p BRANCH_NAME="请输入分支名 [main]: "
    if "!BRANCH_NAME!"=="" set BRANCH_NAME=main
    
    :: 备份原文件
    copy worker.js worker.js.backup >nul
    
    :: 使用 PowerShell 进行替换（更可靠）
    powershell -Command "(Get-Content worker.js) -replace 'YOUR_GITHUB_USERNAME', '!GITHUB_USERNAME!' | Set-Content worker.js"
    powershell -Command "(Get-Content worker.js) -replace \"repo: 'iptv4'\", \"repo: '!REPO_NAME!'\" | Set-Content worker.js"
    powershell -Command "(Get-Content worker.js) -replace \"branch: 'main'\", \"branch: '!BRANCH_NAME!'\" | Set-Content worker.js"
    
    call :print_success "GitHub 配置已更新"
    call :print_info "用户名: !GITHUB_USERNAME!"
    call :print_info "仓库名: !REPO_NAME!"
    call :print_info "分支名: !BRANCH_NAME!"
) else (
    call :print_success "GitHub 配置已完成"
)

:: 检查 Git 仓库状态
call :print_header "检查 Git 仓库状态"

if exist ".git" (
    call :print_success "Git 仓库已存在"
    
    :: 检查是否有未提交的更改
    git diff-index --quiet HEAD -- >nul 2>&1
    if !errorlevel! neq 0 (
        call :print_warning "检测到未提交的更改"
        set /p DO_COMMIT="是否提交更改? (y/n): "
        if /i "!DO_COMMIT!"=="y" (
            git add .
            set /p COMMIT_MSG="请输入提交信息 [Update configuration]: "
            if "!COMMIT_MSG!"=="" set COMMIT_MSG=Update configuration
            git commit -m "!COMMIT_MSG!"
            call :print_success "更改已提交"
            
            set /p DO_PUSH="是否推送到远程仓库? (y/n): "
            if /i "!DO_PUSH!"=="y" (
                git push
                if !errorlevel! equ 0 (
                    call :print_success "已推送到远程仓库"
                ) else (
                    call :print_warning "推送失败，请检查远程仓库配置"
                )
            )
        )
    ) else (
        call :print_success "没有未提交的更改"
    )
) else (
    call :print_warning "当前目录不是 Git 仓库"
    set /p INIT_GIT="是否初始化 Git 仓库? (y/n): "
    if /i "!INIT_GIT!"=="y" (
        git init
        call :print_success "Git 仓库初始化完成"
    ) else (
        call :print_warning "跳过 Git 初始化"
    )
)

:: 部署到 Cloudflare Workers
call :print_header "部署到 Cloudflare Workers"

call :print_info "正在部署..."

wrangler deploy
if %errorlevel% equ 0 (
    call :print_success "部署成功！"
    echo.
    call :print_info "你的 Worker 已部署，可以通过以下方式访问："
    echo.
    
    :: 尝试获取 Worker URL
    for /f "tokens=*" %%i in ('wrangler deployments list 2^>nul ^| findstr "https://"') do (
        set WORKER_URL=%%i
        call :print_success "Worker URL: !WORKER_URL!"
        echo.
        call :print_info "测试访问："
        echo   - 首页: !WORKER_URL!
        echo   - IPTV4 完整版: !WORKER_URL!/iptv4/iptv4
        echo   - IPTV4 精简版: !WORKER_URL!/iptv4/simple_iptv4
    )
) else (
    call :print_error "部署失败"
    pause
    exit /b 1
)

:: 显示后续步骤
call :print_header "后续步骤"

echo 1. 📺 在 IPTV 播放器中添加订阅源
echo 2. 🔧 如需自定义域名，请访问 Cloudflare Dashboard
echo 3. 📝 查看 DEPLOYMENT.md 了解更多配置选项
echo 4. 📖 查看 ADD_SOURCE.md 了解如何添加新的直播源
echo.
call :print_success "部署完成！享受你的 IPTV 服务吧！"
echo.

pause