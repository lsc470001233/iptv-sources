# 🚀 部署指南

本文档详细说明如何将 IPTV 直播源项目部署到 Cloudflare Workers。

## 📋 前置要求

- GitHub 账号
- Cloudflare 账号（免费版即可）
- Node.js 16+ （如果使用 Wrangler CLI）

## 🎯 部署步骤

### 步骤 1：准备 GitHub 仓库

#### 1.1 Fork 或创建仓库

**选项 A：Fork 现有仓库**
1. 访问本项目的 GitHub 页面
2. 点击右上角的 `Fork` 按钮
3. 等待 Fork 完成

**选项 B：创建新仓库**
1. 在 GitHub 创建新仓库，命名为 `iptv4`
2. 将本项目文件上传到仓库
3. 确保仓库是 Public（公开）状态

#### 1.2 确认文件结构

确保你的仓库包含以下文件：
```
iptv4/
├── iptv4/
│   ├── iptv4.txt
│   └── simple_iptv4.txt
├── worker.js
├── wrangler.toml
└── README.md
```

### 步骤 2：配置 Worker 脚本

#### 2.1 修改 GitHub 配置

编辑 `worker.js` 文件，找到以下部分：

```javascript
const GITHUB_CONFIG = {
  owner: 'YOUR_GITHUB_USERNAME',  // 改为你的 GitHub 用户名
  repo: 'iptv4',                   // 改为你的仓库名
  branch: 'main'                   // 确认分支名（main 或 master）
};
```

**示例：**
```javascript
const GITHUB_CONFIG = {
  owner: 'zhangsan',      // 你的 GitHub 用户名
  repo: 'iptv4',          // 仓库名
  branch: 'main'          // 分支名
};
```

#### 2.2 提交更改

```bash
git add worker.js
git commit -m "Update GitHub config"
git push origin main
```

### 步骤 3：部署到 Cloudflare Workers

有两种部署方式，选择其中一种即可。

---

## 方式 A：使用 Wrangler CLI（推荐）

### 3.1 安装 Wrangler

```bash
# 使用 npm 安装
npm install -g wrangler

# 或使用 yarn
yarn global add wrangler
```

### 3.2 登录 Cloudflare

```bash
wrangler login
```

这会打开浏览器，要求你授权 Wrangler 访问你的 Cloudflare 账号。

### 3.3 配置 wrangler.toml

编辑 `wrangler.toml` 文件：

```toml
name = "iptv4-worker"           # Worker 名称，可自定义
main = "worker.js"              # 入口文件
compatibility_date = "2024-01-01"
workers_dev = true              # 启用 workers.dev 域名
```

### 3.4 部署 Worker

```bash
# 在项目根目录执行
wrangler deploy
```

部署成功后，你会看到类似输出：
```
✨ Success! Uploaded 1 file (X.XX sec)
Published iptv4-worker (X.XX sec)
  https://iptv4-worker.your-subdomain.workers.dev
```

### 3.5 测试访问

访问输出的 URL，例如：
```
https://iptv4-worker.your-subdomain.workers.dev/iptv4/iptv4
```

---

## 方式 B：使用 Cloudflare Dashboard

### 3.1 登录 Cloudflare

访问 [Cloudflare Dashboard](https://dash.cloudflare.com/) 并登录。

### 3.2 创建 Worker

1. 在左侧菜单选择 `Workers & Pages`
2. 点击 `Create Application`
3. 选择 `Create Worker`
4. 输入 Worker 名称，例如 `iptv4-worker`
5. 点击 `Deploy`

### 3.3 编辑 Worker 代码

1. 在 Worker 页面点击 `Quick Edit`
2. 删除默认代码
3. 复制 `worker.js` 的全部内容
4. 粘贴到编辑器中
5. 点击 `Save and Deploy`

### 3.4 测试访问

点击 Worker 页面上的预览链接，或访问：
```
https://iptv4-worker.your-subdomain.workers.dev/iptv4/iptv4
```

---

## 步骤 4：配置自定义域名（可选）

### 4.1 添加域名到 Cloudflare

如果你有自己的域名：

1. 在 Cloudflare Dashboard 添加你的域名
2. 按照提示修改域名的 DNS 服务器
3. 等待 DNS 生效（通常几分钟到几小时）

### 4.2 绑定域名到 Worker

**方法 A：使用 Dashboard**

1. 进入你的 Worker 页面
2. 点击 `Settings` → `Triggers`
3. 在 `Custom Domains` 部分点击 `Add Custom Domain`
4. 输入域名，例如 `iptv.yourdomain.com`
5. 点击 `Add Custom Domain`

**方法 B：使用 Wrangler**

编辑 `wrangler.toml`：

```toml
routes = [
  { pattern = "iptv.yourdomain.com/*", zone_name = "yourdomain.com" }
]
```

然后重新部署：
```bash
wrangler deploy
```

### 4.3 测试自定义域名

访问你的自定义域名：
```
https://iptv.yourdomain.com/iptv4/iptv4
```

---

## 🔍 验证部署

### 测试清单

- [ ] 访问根路径显示使用说明页面
- [ ] 访问 `/iptv4/iptv4` 返回完整直播源
- [ ] 访问 `/iptv4/simple_iptv4` 返回精简直播源
- [ ] 在 IPTV 播放器中测试订阅源
- [ ] 检查响应头包含 CORS 支持

### 测试命令

```bash
# 测试根路径
curl https://your-worker-url.workers.dev/

# 测试完整版直播源
curl https://your-worker-url.workers.dev/iptv4/iptv4

# 测试精简版直播源
curl https://your-worker-url.workers.dev/iptv4/simple_iptv4

# 检查响应头
curl -I https://your-worker-url.workers.dev/iptv4/iptv4
```

---

## 🛠️ 故障排查

### 问题 1：404 Not Found

**可能原因：**
- GitHub 配置错误
- 仓库不是 Public
- 文件路径错误

**解决方法：**
1. 检查 `worker.js` 中的 GitHub 配置
2. 确保仓库是公开的
3. 确认文件路径：`iptv4/iptv4.txt`

### 问题 2：CORS 错误

**可能原因：**
- Worker 代码中缺少 CORS 头

**解决方法：**
确保响应包含以下头：
```javascript
'Access-Control-Allow-Origin': '*'
```

### 问题 3：缓存问题

**可能原因：**
- Cloudflare 缓存了旧内容

**解决方法：**
1. 在 Cloudflare Dashboard 清除缓存
2. 或等待缓存过期（默认1小时）

### 问题 4：部署失败

**可能原因：**
- Wrangler 未正确安装
- 未登录 Cloudflare
- 配置文件错误

**解决方法：**
```bash
# 检查 Wrangler 版本
wrangler --version

# 重新登录
wrangler logout
wrangler login

# 检查配置
wrangler whoami
```

---

## 📊 监控和维护

### 查看使用统计

1. 登录 Cloudflare Dashboard
2. 进入 `Workers & Pages`
3. 选择你的 Worker
4. 查看 `Metrics` 标签

### 更新直播源

1. 编辑 GitHub 仓库中的 `.txt` 文件
2. 提交更改
3. 等待缓存过期或手动清除缓存

### 更新 Worker 代码

**使用 Wrangler：**
```bash
wrangler deploy
```

**使用 Dashboard：**
1. 进入 Worker 页面
2. 点击 `Quick Edit`
3. 修改代码
4. 点击 `Save and Deploy`

---

## 🔒 安全建议

1. **定期更新**：保持 Worker 代码和依赖更新
2. **监控流量**：关注异常流量，防止滥用
3. **限制访问**：如需要，可添加访问控制
4. **备份数据**：定期备份直播源文件

---

## 💡 优化建议

### 提升性能

1. **调整缓存时间**：根据更新频率调整
```javascript
'Cache-Control': 'public, max-age=7200' // 2小时
```

2. **启用压缩**：Cloudflare 自动启用 Gzip/Brotli

3. **使用 CDN**：Cloudflare 自动提供全球 CDN

### 降低成本

1. **使用免费版**：Cloudflare Workers 免费版足够使用
2. **优化请求**：减少不必要的 GitHub API 调用
3. **合理缓存**：避免频繁请求源站

---

## 📞 获取帮助

如果遇到问题：

1. 查看 [Cloudflare Workers 文档](https://developers.cloudflare.com/workers/)
2. 访问 [Cloudflare 社区](https://community.cloudflare.com/)
3. 提交 [GitHub Issue](../../issues)

---

## ✅ 部署完成

恭喜！你已成功部署 IPTV 直播源服务。

**下一步：**
- 在播放器中测试订阅源
- 分享给朋友使用
- 定期更新直播源
- 监控服务状态

**访问地址：**
```
https://your-worker-url.workers.dev/iptv4/iptv4
```

或自定义域名：
```
https://iptv.yourdomain.com/iptv4/iptv4
```

---

**🎉 享受你的 IPTV 直播服务吧！**