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

# 需要处理的页面
PAGES=(index.html book.html lesson.html)

# 先清理历史错误注入的文本行（如果出现过）
for page in "${PAGES[@]}"; do
  f="dist/$page"
  [ -f "$f" ] || continue
  # 删除包含 read -r -d 或 FOOTER_HTML << 的行
  sed -i '/read -r -d/d' "$f" || true
  sed -i '/FOOTER_HTML <</d' "$f" || true
done

# 生成一个可插入的片段（移除旧 footer + 插入新 footer）
cat > dist/footer_snippet.html <<'EOF'
<script>
(function(){
  try {
    // 移除旧 footer
    document.querySelectorAll('footer').forEach(function(el){ el.remove(); });
    // 移除如果页面中残留的错误文本
    document.body.innerHTML = document.body.innerHTML
      .replace(/read -r -d[^<]*FOOTER_HTML <<'EOF'/gi, '')
      .replace(/FOOTER_HTML <<'EOF'/gi, '');
  } catch(e){}
})();
</script>
<footer style="text-align:center;padding:16px 0;color:#666;font-size:14px;">
   凉风有信 © 2025 ｜Thanks to Luzhenhua ｜Qmail：mylsm
</footer>
EOF

echo "Injecting footer snippet before </body> ..."
for page in "${PAGES[@]}"; do
  f="dist/$page"
  [ -f "$f" ] || continue
  awk 'BEGIN{IGNORECASE=1} {print} /<\/body>/{system("cat dist/footer_snippet.html")} ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
done

echo "Build finished. dist/ is ready."
