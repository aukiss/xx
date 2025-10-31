#!/usr/bin/env bash
set -euo pipefail

# 清理
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

# 删除上游自定义域名
rm -f dist/CNAME || true

# 注入 Netlify headers 与 404 页面
cp _headers dist/_headers
cp 404.html dist/404.html

# 生成一个可插入的片段（包含移除旧 footer 的脚本 + 新 footer）
cat > dist/footer_snippet.html <<'EOF'
<script>
(function(){
  try {
    var old = document.getElementsByTagName('footer');
    while (old.length) { old[0].parentNode.removeChild(old[0]); }
  } catch(e){}
})();
</script>
read -r -d '' FOOTER_HTML <<'EOF'
<footer style="text-align:center;padding:16px 0;color:#666;font-size:14px;">
  凉风有信 © 2025 ｜Thanks to Luzhenhua ｜Qmail：mylsm ｜<a href="/" style="color:#0b6cff;text-decoration:none;">返回首页</a>
</footer>
EOF

echo "Injecting footer snippet before </body> ..."
PAGES=(index.html book.html lesson.html)
for page in "${PAGES[@]}"; do
  f="dist/$page"
  [ -f "$f" ] || continue
  awk 'BEGIN{IGNORECASE=1} {print} /<\/body>/{system("cat dist/footer_snippet.html")} ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
done

echo "Build finished. dist/ is ready."
