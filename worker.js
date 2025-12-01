/**
 * IPTV 直播源 Cloudflare Worker
 * 用于托管和分发 IPTV 直播源文件
 */

// GitHub 仓库配置
const GITHUB_CONFIG = {
  owner: 'lsc470001233',  // 替换为你的 GitHub 用户名
  repo: 'iptv-sources',                   // 替换为你的仓库名
  branch: 'main'                   // 分支名
};

// 构建 GitHub Raw 文件 URL
function getGitHubRawUrl(filePath) {
  return `https://raw.githubusercontent.com/${GITHUB_CONFIG.owner}/${GITHUB_CONFIG.repo}/${GITHUB_CONFIG.branch}/${filePath}`;
}

// 处理请求
async function handleRequest(request) {
  const url = new URL(request.url);
  const pathname = url.pathname;

  // 移除开头的斜杠
  const path = pathname.substring(1);

  // 如果是根路径，返回使用说明
  if (!path || path === '/') {
    return new Response(getUsageHTML(), {
      headers: {
        'Content-Type': 'text/html; charset=utf-8',
        'Access-Control-Allow-Origin': '*'
      }
    });
  }

  // 处理文件请求
  // 支持的格式：/iptv4/iptv4 或 /iptv4/iptv4.txt
  let filePath = path;
  
  // 如果路径不包含扩展名，自动添加 .txt
  if (!filePath.includes('.')) {
    filePath += '.txt';
  }

  try {
    // 从 GitHub 获取文件
    const githubUrl = getGitHubRawUrl(filePath);
    const response = await fetch(githubUrl);

    if (!response.ok) {
      return new Response(`文件未找到: ${filePath}`, {
        status: 404,
        headers: {
          'Content-Type': 'text/plain; charset=utf-8',
          'Access-Control-Allow-Origin': '*'
        }
      });
    }

    // 获取文件内容
    const content = await response.text();

    // 返回文件内容
    return new Response(content, {
      headers: {
        'Content-Type': 'text/plain; charset=utf-8',
        'Access-Control-Allow-Origin': '*',
        'Cache-Control': 'public, max-age=3600', // 缓存1小时
        'X-Content-Type-Options': 'nosniff'
      }
    });

  } catch (error) {
    return new Response(`获取文件失败: ${error.message}`, {
      status: 500,
      headers: {
        'Content-Type': 'text/plain; charset=utf-8',
        'Access-Control-Allow-Origin': '*'
      }
    });
  }
}

// 使用说明 HTML
function getUsageHTML() {
  return `<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>IPTV 直播源服务</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background: white;
            border-radius: 10px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.1);
            padding: 40px;
        }
        h1 {
            color: #667eea;
            margin-bottom: 10px;
            font-size: 2em;
        }
        .subtitle {
            color: #666;
            margin-bottom: 30px;
            font-size: 1.1em;
        }
        .section {
            margin-bottom: 30px;
        }
        h2 {
            color: #764ba2;
            margin-bottom: 15px;
            font-size: 1.5em;
            border-bottom: 2px solid #667eea;
            padding-bottom: 10px;
        }
        .code-block {
            background: #f5f5f5;
            border-left: 4px solid #667eea;
            padding: 15px;
            margin: 10px 0;
            border-radius: 4px;
            overflow-x: auto;
        }
        code {
            font-family: "Courier New", Courier, monospace;
            color: #e83e8c;
        }
        .example {
            background: #e8f4f8;
            padding: 15px;
            border-radius: 4px;
            margin: 10px 0;
        }
        .note {
            background: #fff3cd;
            border-left: 4px solid #ffc107;
            padding: 15px;
            margin: 15px 0;
            border-radius: 4px;
        }
        ul {
            margin-left: 20px;
            margin-top: 10px;
        }
        li {
            margin: 8px 0;
        }
        a {
            color: #667eea;
            text-decoration: none;
        }
        a:hover {
            text-decoration: underline;
        }
        .footer {
            text-align: center;
            margin-top: 40px;
            padding-top: 20px;
            border-top: 1px solid #eee;
            color: #666;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>📺 IPTV 直播源服务</h1>
        <p class="subtitle">基于 Cloudflare Worker 的 IPTV 直播源托管服务</p>

        <div class="section">
            <h2>🚀 使用方法</h2>
            <p>访问以下格式的 URL 获取直播源：</p>
            <div class="code-block">
                <code>https://your-domain.com/iptv4/iptv4</code><br>
                <code>https://your-domain.com/iptv4/simple_iptv4</code>
            </div>
            <div class="note">
                <strong>💡 提示：</strong> 可以省略 .txt 扩展名，系统会自动添加
            </div>
        </div>

        <div class="section">
            <h2>📋 可用源列表</h2>
            <ul>
                <li><strong>完整版：</strong> <code>/iptv4/iptv4</code> - 包含所有频道（1300+ 个）</li>
                <li><strong>精简版：</strong> <code>/iptv4/simple_iptv4</code> - 精选常用频道（400+ 个）</li>
            </ul>
        </div>

        <div class="section">
            <h2>🎯 使用示例</h2>
            <div class="example">
                <p><strong>在播放器中使用：</strong></p>
                <ol>
                    <li>复制源地址：<code>https://your-domain.com/iptv4/iptv4</code></li>
                    <li>在 IPTV 播放器中添加订阅源</li>
                    <li>刷新频道列表即可观看</li>
                </ol>
            </div>
        </div>

        <div class="section">
            <h2>📱 推荐播放器</h2>
            <ul>
                <li><strong>Android：</strong> IPTV Pro, TiviMate, Perfect Player</li>
                <li><strong>iOS：</strong> GSE Smart IPTV, IPTV Smarters Pro</li>
                <li><strong>Windows：</strong> VLC Media Player, PotPlayer</li>
                <li><strong>Mac：</strong> VLC Media Player, IINA</li>
            </ul>
        </div>

        <div class="section">
            <h2>⚙️ 技术特性</h2>
            <ul>
                <li>✅ 基于 Cloudflare CDN，全球加速</li>
                <li>✅ 支持跨域访问（CORS）</li>
                <li>✅ 智能缓存，提升访问速度</li>
                <li>✅ 自动同步 GitHub 仓库更新</li>
                <li>✅ 支持 HTTPS 安全访问</li>
            </ul>
        </div>

        <div class="footer">
            <p>Powered by Cloudflare Workers | 数据源自 GitHub</p>
        </div>
    </div>
</body>
</html>`;
}

// 处理 CORS 预检请求
async function handleOptions(request) {
  return new Response(null, {
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
      'Access-Control-Max-Age': '86400',
    }
  });
}

// 主入口
addEventListener('fetch', event => {
  const request = event.request;
  
  if (request.method === 'OPTIONS') {
    event.respondWith(handleOptions(request));
  } else if (request.method === 'GET') {
    event.respondWith(handleRequest(request));
  } else {
    event.respondWith(new Response('Method Not Allowed', { status: 405 }));
  }
});