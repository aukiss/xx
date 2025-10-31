#!/usr/bin/env bash
set -euo pipefail

# 清理旧目录
rm -rf dist
mkdir -p dist

echo "Downloading latest NCE-Flow (main branch) zip..."
ZIP_URL="https://codeload.github.com/luzhenhua/NCE-Flow/zip/refs/heads/main"
curl -L "$ZIP_URL" -o /tmp/nce-flow.zip

echo "Unzipping..."
unzip -q /tmp/nce-flow.zip -d /tmp
SRC_DIR="/tmp/NCE-Flow-main"

# 拷贝源码到 dist
rsync -a "$SRC_DIR"/ dist/

# 删除原域名绑定文件
rm -f dist/CNAME

# 注入 Netlify headers 与 404 页面
cp _headers dist/_headers
cp 404.html dist/404.html

# -------------------------------
# 👇👇👇 自动修改底部信息 👇👇👇
echo "Updating footer text..."
FOOTER_HTML='<footer style="text-align:center;padding:16px 0;color:#666;font-size:14px;">
牛爸小课堂 © 2025 ｜用于个人学习 ｜邮箱：mylsm@qq.com ｜<a href="/" style="color:#0b6cff;text-decoration:none;">返回首页</a>
</footer>'

for page in index.html book.html lesson.html; do
  if [ -f "dist/$page" ]; then
    sed -i "s|<footer>.*</footer>|$FOOTER_HTML|g" "dist/$page" || true
  fi
done
# -------------------------------

echo "Build finished. dist/ is ready."
