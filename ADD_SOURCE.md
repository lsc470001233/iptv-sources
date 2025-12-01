# 📺 新增直播源指南

本文档说明如何向项目中添加新的 IPTV 直播源文件。

## 🎯 快速添加新源

### 方法 1：添加新的源文件夹

假设你要添加 `iptv6` 源：

#### 步骤 1：创建文件夹和源文件

```bash
# 在项目根目录执行
mkdir iptv6
```

#### 步骤 2：创建源文件

在 `iptv6` 文件夹中创建 `iptv6.txt` 文件，格式如下：

```
央视频道,#genre#
CCTV1,http://example.com/cctv1.m3u8
CCTV2,http://example.com/cctv2.m3u8

卫视频道,#genre#
湖南卫视,http://example.com/hunan.m3u8
浙江卫视,http://example.com/zhejiang.m3u8
```

#### 步骤 3：提交到 GitHub

```bash
git add iptv6/
git commit -m "Add iptv6 source"
git push origin main
```

#### 步骤 4：访问新源

部署后，通过以下 URL 访问：
```
https://your-worker-url.workers.dev/iptv6/iptv6
```

---

### 方法 2：在现有文件夹中添加新文件

假设你要在 `iptv4` 文件夹中添加 `sports.txt`（体育频道）：

#### 步骤 1：创建源文件

在 `iptv4` 文件夹中创建 `sports.txt`：

```
体育频道,#genre#
CCTV5,http://example.com/cctv5.m3u8
CCTV5+,http://example.com/cctv5plus.m3u8
广东体育,http://example.com/gdtv-sports.m3u8
```

#### 步骤 2：提交到 GitHub

```bash
git add iptv4/sports.txt
git commit -m "Add sports channels"
git push origin main
```

#### 步骤 3：访问新源

```
https://your-worker-url.workers.dev/iptv4/sports
```

---

## 📝 源文件格式说明

### 基本格式

```
分类名称,#genre#
频道名称,直播源URL
频道名称,直播源URL

另一个分类,#genre#
频道名称,直播源URL
```

### 格式规则

1. **分类行**：`分类名称,#genre#`
   - 用于分组频道
   - 必须以 `,#genre#` 结尾

2. **频道行**：`频道名称,直播源URL`
   - 频道名称和 URL 用逗号分隔
   - 支持多个相同频道名称（不同源）

3. **空行**：用于分隔不同分类（可选）

### 示例文件

```
央视频道,#genre#
CCTV1,http://source1.com/cctv1.m3u8
CCTV1,http://source2.com/cctv1.m3u8
CCTV2,http://source1.com/cctv2.m3u8

卫视频道,#genre#
湖南卫视,http://source1.com/hunan.m3u8
浙江卫视,http://source1.com/zhejiang.m3u8

地方频道,#genre#
北京卫视,http://source1.com/beijing.m3u8
上海东方卫视,http://source1.com/shanghai.m3u8
```

---

## 🗂️ 推荐的文件组织结构

### 按地区分类

```
iptv4/
├── mainland.txt      # 大陆频道
├── hongkong.txt      # 香港频道
├── taiwan.txt        # 台湾频道
└── international.txt # 国际频道
```

访问方式：
- `https://your-worker-url.workers.dev/iptv4/mainland`
- `https://your-worker-url.workers.dev/iptv4/hongkong`

### 按类型分类

```
iptv4/
├── news.txt          # 新闻频道
├── sports.txt        # 体育频道
├── movies.txt        # 电影频道
└── entertainment.txt # 娱乐频道
```

### 按质量分类

```
iptv4/
├── hd.txt            # 高清源
├── sd.txt            # 标清源
└── backup.txt        # 备用源
```

### 混合组织（推荐）

```
iptv4/
├── iptv4.txt         # 完整版（所有频道）
├── simple_iptv4.txt  # 精简版（常用频道）
└── premium.txt       # 高级版（高质量源）

iptv6/
├── iptv6.txt         # IPv6 完整版
└── simple_iptv6.txt  # IPv6 精简版

sports/
├── cctv.txt          # CCTV 体育频道
├── local.txt         # 地方体育频道
└── international.txt # 国际体育频道
```

---

## 🔄 批量添加源

### 使用脚本批量创建

创建 `add_sources.sh` 脚本：

```bash
#!/bin/bash

# 定义要创建的源
sources=(
  "iptv6/iptv6.txt"
  "iptv6/simple_iptv6.txt"
  "sports/cctv.txt"
  "sports/local.txt"
  "movies/action.txt"
  "movies/comedy.txt"
)

# 创建文件夹和文件
for source in "${sources[@]}"; do
  dir=$(dirname "$source")
  mkdir -p "$dir"
  
  # 创建示例内容
  cat > "$source" << EOF
示例分类,#genre#
示例频道1,http://example.com/channel1.m3u8
示例频道2,http://example.com/channel2.m3u8
EOF
  
  echo "Created: $source"
done

echo "All sources created!"
```

执行脚本：
```bash
chmod +x add_sources.sh
./add_sources.sh
```

### Windows 批处理脚本

创建 `add_sources.bat`：

```batch
@echo off
setlocal enabledelayedexpansion

:: 创建 iptv6 源
mkdir iptv6 2>nul
echo 示例分类,#genre# > iptv6\iptv6.txt
echo 示例频道1,http://example.com/channel1.m3u8 >> iptv6\iptv6.txt

:: 创建 sports 源
mkdir sports 2>nul
echo 体育频道,#genre# > sports\cctv.txt
echo CCTV5,http://example.com/cctv5.m3u8 >> sports\cctv.txt

echo All sources created!
pause
```

---

## ✅ 验证新源

### 1. 本地验证

在提交前，检查文件格式：

```bash
# 检查文件是否存在
ls -la iptv6/iptv6.txt

# 查看文件内容
cat iptv6/iptv6.txt

# 检查文件编码（应为 UTF-8）
file -i iptv6/iptv6.txt
```

### 2. 格式验证

确保文件符合以下要求：
- ✅ 使用 UTF-8 编码
- ✅ 每行格式正确
- ✅ 分类行以 `,#genre#` 结尾
- ✅ URL 格式正确
- ✅ 没有多余的空格

### 3. 部署后验证

```bash
# 测试新源是否可访问
curl https://your-worker-url.workers.dev/iptv6/iptv6

# 检查响应状态
curl -I https://your-worker-url.workers.dev/iptv6/iptv6

# 在播放器中测试
# 将 URL 添加到 IPTV 播放器的订阅列表
```

---

## 🔧 常见问题

### Q1：新增源后无法访问？

**可能原因：**
- GitHub 仓库未更新
- Cloudflare 缓存未刷新
- 文件路径错误

**解决方法：**
```bash
# 1. 确认文件已推送到 GitHub
git status
git push origin main

# 2. 等待缓存过期（1小时）或手动清除
# 在 Cloudflare Dashboard 清除缓存

# 3. 检查文件路径
# 确保路径为：folder/filename.txt
```

### Q2：如何批量更新多个源？

```bash
# 1. 修改所有源文件
# 2. 一次性提交
git add .
git commit -m "Update all sources"
git push origin main

# 3. 清除 Cloudflare 缓存
```

### Q3：源文件太大怎么办？

**建议：**
- 将大文件拆分为多个小文件
- 按分类或地区拆分
- 创建精简版和完整版

**示例：**
```
iptv4/
├── iptv4_full.txt    # 完整版（1000+ 频道）
├── iptv4_simple.txt  # 精简版（100+ 频道）
├── iptv4_cctv.txt    # 仅 CCTV
└── iptv4_local.txt   # 仅地方台
```

---

## 📊 源文件管理最佳实践

### 1. 命名规范

- 使用小写字母和下划线
- 使用描述性名称
- 避免特殊字符

**好的命名：**
```
iptv6.txt
simple_iptv6.txt
sports_cctv.txt
movies_action.txt
```

**不好的命名：**
```
IPTV6.TXT
iptv-6.txt
体育频道.txt
source#1.txt
```

### 2. 版本控制

在文件开头添加版本信息：

```
# IPTV6 直播源
# 版本：v1.0.0
# 更新时间：2024-01-01
# 频道数量：500+

央视频道,#genre#
CCTV1,http://example.com/cctv1.m3u8
```

### 3. 定期维护

- 每周检查失效链接
- 每月更新源列表
- 记录更新日志

创建 `CHANGELOG.md`：

```markdown
# 更新日志

## 2024-01-01
- 新增 iptv6 源（500+ 频道）
- 更新 iptv4 源（修复 50+ 失效链接）
- 优化分类结构

## 2023-12-01
- 初始版本发布
```

---

## 🚀 快速参考

### 添加新源的完整流程

```bash
# 1. 创建文件夹
mkdir iptv6

# 2. 创建源文件
cat > iptv6/iptv6.txt << 'EOF'
央视频道,#genre#
CCTV1,http://example.com/cctv1.m3u8
CCTV2,http://example.com/cctv2.m3u8
EOF

# 3. 提交到 GitHub
git add iptv6/
git commit -m "Add iptv6 source"
git push origin main

# 4. 等待部署（自动）或手动清除缓存

# 5. 测试访问
curl https://your-worker-url.workers.dev/iptv6/iptv6
```

### 访问 URL 格式

```
https://your-worker-url.workers.dev/{folder}/{filename}

示例：
https://your-worker-url.workers.dev/iptv4/iptv4
https://your-worker-url.workers.dev/iptv6/iptv6
https://your-worker-url.workers.dev/sports/cctv
```

---

## 💡 高级技巧

### 1. 使用 Git 子模块管理源

如果源文件来自其他仓库：

```bash
git submodule add https://github.com/user/iptv-sources.git sources
```

### 2. 自动化源更新

创建 GitHub Actions 工作流（`.github/workflows/update-sources.yml`）：

```yaml
name: Update Sources
on:
  schedule:
    - cron: '0 0 * * *'  # 每天更新
  workflow_dispatch:

jobs:
  update:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Update sources
        run: |
          # 你的更新脚本
          ./update_sources.sh
      - name: Commit changes
        run: |
          git config --local user.email "action@github.com"
          git config --local user.name "GitHub Action"
          git add .
          git commit -m "Auto update sources" || exit 0
          git push
```

### 3. 源文件加密（可选）

如果需要保护源文件：

```bash
# 加密文件
openssl enc -aes-256-cbc -salt -in iptv6.txt -out iptv6.txt.enc

# 在 Worker 中解密（需要修改 worker.js）
```

---

**🎉 现在你可以轻松添加和管理任意数量的直播源了！**