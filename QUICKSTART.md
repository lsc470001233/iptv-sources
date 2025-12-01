# 🚀 快速开始指南

本指南将帮助你在 5 分钟内完成 IPTV 直播源的部署。

## 📋 前置要求

- GitHub 账号
- Cloudflare 账号（免费版即可）
- Node.js 16+ 和 npm

## ⚡ 三步快速部署

### 步骤 1️⃣：准备项目

#### 方式 A：使用自动化脚本（推荐）

**Linux/macOS:**
```bash
# 1. 克隆或下载项目
git clone https://github.com/YOUR_USERNAME/iptv4.git
cd iptv4

# 2. 运行部署脚本
chmod +x deploy.sh
./deploy.sh
```

**Windows:**
```cmd
# 1. 克隆或下载项目
git clone https://github.com/YOUR_USERNAME/iptv4.git
cd iptv4

# 2. 运行部署脚本
deploy.bat
```

脚本会自动完成以下操作：
- ✅ 检查环境依赖
- ✅ 安装 Wrangler（如需要）
- ✅ 登录 Cloudflare
- ✅ 配置 GitHub 信息
- ✅ 部署到 Cloudflare Workers

#### 方式 B：手动部署

如果你更喜欢手动控制每一步：

```bash
# 1. 安装 Wrangler
npm install -g wrangler

# 2. 登录 Cloudflare
wrangler login

# 3. 配置 GitHub 信息
# 编辑 worker.js，修改第 10-14 行：
# owner: 'YOUR_GITHUB_USERNAME'  -> 改为你的 GitHub 用户名
# repo: 'iptv4'                   -> 改为你的仓库名
# branch: 'main'                  -> 确认分支名

# 4. 部署
wrangler deploy
```

### 步骤 2️⃣：推送到 GitHub

```bash
# 1. 初始化 Git（如果还没有）
git init

# 2. 添加文件
git add .

# 3. 提交
git commit -m "Initial commit"

# 4. 添加远程仓库
git remote add origin https://github.com/YOUR_USERNAME/iptv4.git

# 5. 推送
git push -u origin main
```

**重要：** 确保你的 GitHub 仓库是 **Public（公开）** 状态！

### 步骤 3️⃣：测试访问

部署成功后，你会看到类似输出：

```
✨ Success! Uploaded 1 file
Published iptv4-worker
  https://iptv4-worker.your-subdomain.workers.dev
```

访问以下 URL 测试：

- **首页**：`https://iptv4-worker.your-subdomain.workers.dev/`
- **完整版**：`https://iptv4-worker.your-subdomain.workers.dev/iptv4/iptv4`
- **精简版**：`https://iptv4-worker.your-subdomain.workers.dev/iptv4/simple_iptv4`

## 📺 在播放器中使用

### Android - IPTV Pro

1. 打开 IPTV Pro
2. 点击 "+" 添加播放列表
3. 选择 "URL"
4. 输入订阅地址：`https://your-worker-url.workers.dev/iptv4/iptv4`
5. 点击 "确定"

### iOS - iPlayTV

1. 打开 iPlayTV
2. 点击 "设置" → "播放列表"
3. 点击 "+" 添加
4. 输入订阅地址：`https://your-worker-url.workers.dev/iptv4/iptv4`
5. 点击 "保存"

### Windows - PotPlayer

1. 打开 PotPlayer
2. 右键 → "打开" → "打开链接"
3. 输入：`https://your-worker-url.workers.dev/iptv4/iptv4`
4. 点击 "确定"

### macOS - IINA

1. 打开 IINA
2. 文件 → 打开 URL
3. 输入：`https://your-worker-url.workers.dev/iptv4/iptv4`
4. 点击 "打开"

## 🎯 添加新的直播源

### 快速添加 iptv6 源

```bash
# 1. 创建文件夹
mkdir iptv6

# 2. 创建源文件
cat > iptv6/iptv6.txt << 'EOF'
央视频道,#genre#
CCTV1,http://example.com/cctv1.m3u8
CCTV2,http://example.com/cctv2.m3u8

卫视频道,#genre#
湖南卫视,http://example.com/hunan.m3u8
浙江卫视,http://example.com/zhejiang.m3u8
EOF

# 3. 提交到 GitHub
git add iptv6/
git commit -m "Add iptv6 source"
git push origin main

# 4. 访问新源
# https://your-worker-url.workers.dev/iptv6/iptv6
```

### 源文件格式

```
分类名称,#genre#
频道名称,直播源URL
频道名称,直播源URL

另一个分类,#genre#
频道名称,直播源URL
```

**示例：**
```
央视频道,#genre#
CCTV1,http://58.57.40.22:9901/tsfile/live/0001_1.m3u8
CCTV1,http://play.kankanlive.com/live/1661761962676984.m3u8
CCTV2,http://112.123.206.32:808/hls/2/index.m3u8

卫视频道,#genre#
湖南卫视,http://example.com/hunan.m3u8
浙江卫视,http://example.com/zhejiang.m3u8
```

## 🔧 常见问题

### Q1：部署后访问 404？

**检查清单：**
- [ ] GitHub 仓库是否为 Public
- [ ] [`worker.js`](worker.js:10) 中的 GitHub 配置是否正确
- [ ] 文件路径是否正确（如 `iptv4/iptv4.txt`）
- [ ] 是否等待缓存过期（默认 1 小时）

**解决方法：**
```bash
# 1. 检查 GitHub 配置
cat worker.js | grep -A 3 "GITHUB_CONFIG"

# 2. 验证文件存在
ls -la iptv4/iptv4.txt

# 3. 重新部署
wrangler deploy
```

### Q2：如何更新直播源？

```bash
# 1. 编辑源文件
nano iptv4/iptv4.txt

# 2. 提交更改
git add iptv4/iptv4.txt
git commit -m "Update sources"
git push origin main

# 3. 等待缓存过期或清除缓存
# 在 Cloudflare Dashboard 清除缓存
```

### Q3：如何使用自定义域名？

**方法 1：Cloudflare Dashboard**
1. 登录 Cloudflare Dashboard
2. 进入你的 Worker
3. Settings → Triggers → Custom Domains
4. 添加自定义域名（如 `iptv.yourdomain.com`）

**方法 2：修改 wrangler.toml**
```toml
routes = [
  { pattern = "iptv.yourdomain.com/*", zone_name = "yourdomain.com" }
]
```

然后重新部署：
```bash
wrangler deploy
```

### Q4：如何查看访问统计？

1. 登录 Cloudflare Dashboard
2. 进入 Workers & Pages
3. 选择你的 Worker
4. 查看 Metrics 标签

### Q5：免费版有限制吗？

Cloudflare Workers 免费版限制：
- ✅ 每天 100,000 次请求
- ✅ 每次请求最多 10ms CPU 时间
- ✅ 足够个人和小团队使用

## 📚 更多文档

- **[README.md](README.md)** - 项目概述和功能介绍
- **[DEPLOYMENT.md](DEPLOYMENT.md)** - 详细部署指南
- **[ADD_SOURCE.md](ADD_SOURCE.md)** - 添加新源的完整指南

## 🆘 获取帮助

遇到问题？

1. 查看 [常见问题](#常见问题)
2. 阅读 [详细部署指南](DEPLOYMENT.md)
3. 访问 [Cloudflare 社区](https://community.cloudflare.com/)
4. 提交 [GitHub Issue](../../issues)

## ✅ 快速命令参考

```bash
# 安装 Wrangler
npm install -g wrangler

# 登录 Cloudflare
wrangler login

# 部署 Worker
wrangler deploy

# 查看部署列表
wrangler deployments list

# 查看日志
wrangler tail

# 删除 Worker
wrangler delete

# 更新 Wrangler
npm update -g wrangler
```

## 🎉 完成！

恭喜！你已经成功部署了 IPTV 直播源服务。

**下一步：**
- 📺 在播放器中测试订阅源
- 🔧 配置自定义域名（可选）
- 📝 添加更多直播源
- 📊 监控访问统计

**访问地址：**
```
https://your-worker-url.workers.dev/iptv4/iptv4
```

**享受你的 IPTV 服务吧！** 🎊