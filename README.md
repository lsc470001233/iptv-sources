# 📺 IPTV 直播源托管项目

基于 GitHub + Cloudflare Worker 的 IPTV 直播源托管解决方案，提供稳定、快速的直播源访问服务。

## 🌟 项目特点

- ✅ **全球加速**：基于 Cloudflare CDN，全球访问速度快
- ✅ **自动同步**：直接从 GitHub 仓库读取，更新即时生效
- ✅ **免费托管**：利用 GitHub 和 Cloudflare 免费服务
- ✅ **支持 CORS**：可在任何网页或应用中使用
- ✅ **智能缓存**：自动缓存优化，减少源站压力
- ✅ **HTTPS 安全**：全程加密传输，安全可靠

## 📋 直播源列表

本项目提供两个版本的直播源：

| 文件名 | 说明 | 频道数量 | 访问路径 |
|--------|------|----------|----------|
| `iptv4.txt` | 完整版 | 1300+ | `/iptv4/iptv4` |
| `simple_iptv4.txt` | 精简版 | 400+ | `/iptv4/simple_iptv4` |

### 频道分类

- 央视频道（CCTV1-17）
- 港澳频道（凤凰卫视、翡翠台等）
- 卫视频道（各省卫视）
- 电影频道
- 地方频道
- 数字频道
- 儿童频道
- 体育频道
- 纪录频道
- 音乐频道
- 春晚频道
- 直播中国（景点直播）

## 🚀 快速开始

### 方式一：直接使用（推荐）

如果项目已部署，直接在 IPTV 播放器中添加以下订阅源：

```
https://your-domain.com/iptv4/iptv4
```

或精简版：

```
https://your-domain.com/iptv4/simple_iptv4
```

### 方式二：自己部署

#### 1. Fork 本仓库

点击右上角 Fork 按钮，将项目复制到你的 GitHub 账号。

#### 2. 修改配置

编辑 [`worker.js`](worker.js) 文件，修改 GitHub 配置：

```javascript
const GITHUB_CONFIG = {
  owner: 'YOUR_GITHUB_USERNAME',  // 改为你的 GitHub 用户名
  repo: 'iptv4',                   // 改为你的仓库名
  branch: 'main'                   // 分支名
};
```

#### 3. 部署到 Cloudflare Workers

**方法 A：使用 Wrangler CLI（推荐）**

```bash
# 安装 Wrangler
npm install -g wrangler

# 登录 Cloudflare
wrangler login

# 部署 Worker
wrangler deploy
```

**方法 B：使用 Cloudflare Dashboard**

1. 登录 [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. 进入 `Workers & Pages`
3. 点击 `Create Application` → `Create Worker`
4. 复制 [`worker.js`](worker.js) 的内容到编辑器
5. 点击 `Save and Deploy`

#### 4. 配置自定义域名（可选）

1. 在 Cloudflare Dashboard 中进入你的 Worker
2. 点击 `Settings` → `Triggers`
3. 添加自定义域名或使用 workers.dev 子域名

## 📱 推荐播放器

### Android
- **IPTV Pro** - 功能强大，界面美观
- **TiviMate** - 专业级 IPTV 播放器
- **Perfect Player** - 简洁易用

### iOS
- **GSE Smart IPTV** - 功能全面
- **IPTV Smarters Pro** - 界面友好

### Windows
- **VLC Media Player** - 开源免费
- **PotPlayer** - 功能强大

### macOS
- **VLC Media Player** - 跨平台支持
- **IINA** - 现代化播放器

## 🎯 使用示例

### 在 VLC 中使用

1. 打开 VLC Media Player
2. 媒体 → 打开网络串流
3. 输入订阅源地址：`https://your-domain.com/iptv4/iptv4`
4. 点击播放

### 在 IPTV Pro 中使用

1. 打开 IPTV Pro
2. 点击右上角 `+` 添加播放列表
3. 选择 `URL`
4. 输入订阅源地址
5. 点击确定

## 📁 项目结构

```
iptv4/
├── iptv4/
│   ├── iptv4.txt           # 完整版直播源
│   └── simple_iptv4.txt    # 精简版直播源
├── worker.js               # Cloudflare Worker 脚本
├── wrangler.toml          # Wrangler 配置文件
└── README.md              # 项目说明文档
```

## 🔧 高级配置

### 修改缓存时间

在 [`worker.js`](worker.js:52) 中修改缓存时间：

```javascript
'Cache-Control': 'public, max-age=3600', // 3600秒 = 1小时
```

### 添加新的直播源文件

1. 在 `iptv4/` 目录下创建新的 `.txt` 文件
2. 按照现有格式添加频道信息
3. 提交到 GitHub
4. 访问 `https://your-domain.com/iptv4/新文件名`

### 自定义首页

修改 [`worker.js`](worker.js:68) 中的 `getUsageHTML()` 函数来自定义首页内容。

## 🛠️ 维护更新

### 更新直播源

1. 编辑 `iptv4/iptv4.txt` 或 `iptv4/simple_iptv4.txt`
2. 提交更改到 GitHub
3. 等待几分钟让缓存过期，或清除 Cloudflare 缓存

### 清除缓存

在 Cloudflare Dashboard 中：
1. 进入你的域名
2. 点击 `Caching` → `Configuration`
3. 点击 `Purge Everything`

## ⚠️ 注意事项

1. **版权声明**：本项目仅供学习交流使用，请勿用于商业用途
2. **直播源稳定性**：直播源来自互联网，稳定性无法保证
3. **流量限制**：Cloudflare Workers 免费版有每日请求限制（10万次）
4. **合规使用**：请遵守当地法律法规，合理使用直播源

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request！

### 提交直播源

如果你有稳定的直播源，欢迎通过以下方式贡献：

1. Fork 本仓库
2. 添加直播源到对应文件
3. 提交 Pull Request
4. 等待审核合并

### 报告问题

发现问题请提交 Issue，包含以下信息：
- 问题描述
- 复现步骤
- 期望结果
- 实际结果

## 📊 API 说明

### 获取直播源

**请求：**
```
GET /iptv4/iptv4
```

**响应：**
```
Content-Type: text/plain; charset=utf-8
Access-Control-Allow-Origin: *
Cache-Control: public, max-age=3600

央视频道,#genre#
CCTV1,http://...
CCTV2,http://...
...
```

### 查看使用说明

**请求：**
```
GET /
```

**响应：**
```
Content-Type: text/html; charset=utf-8

<!DOCTYPE html>
<html>
...
</html>
```

## 📞 联系方式

- GitHub Issues: [提交问题](../../issues)
- Pull Requests: [贡献代码](../../pulls)

## 📄 许可证

本项目采用 MIT 许可证。详见 [LICENSE](LICENSE) 文件。

## 🙏 致谢

- 感谢所有直播源提供者
- 感谢 Cloudflare 提供的免费服务
- 感谢 GitHub 提供的代码托管服务

## 📈 更新日志

### 2025-12-01
- ✨ 初始版本发布
- ✅ 支持完整版和精简版直播源
- ✅ 集成 Cloudflare Worker
- ✅ 添加使用说明页面

---

**⭐ 如果这个项目对你有帮助，请给个 Star 支持一下！**