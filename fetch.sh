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

# 你的底部块
read -r -d '' FOOTER_HTML <<'EOF'
<footer style="text-align:center;padding:16px 0;color:#666;font-size:14px;">
  凉风有信 © 2025 ｜Thanks to Luzhenhua ｜Qmail：mylsm ｜<a href="/" style="color:#0b6cff;text-decoration:none;">返回首页</a>
</footer>
EOF

echo "Patching footer on pages: ${PAGES[*]}"

for page in "${PAGES[@]}"; do
  f="dist/$page"
  [ -f "$f" ] || continue

  # 若已有 <footer>…</footer>，替换；否则插入 </body> 前
  if grep -qi "<footer" "$f"; then
    perl -0777 -pe '
      BEGIN {
        $new = q|'$FOOTER_HTML'|;
      }
      s#<footer\b.*?</footer>#$new#is
    ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  else
    perl -0777 -pe '
      BEGIN {
        $new = q|'$FOOTER_HTML'|;
      }
      s#</body>#$new\n</body>#i
    ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  fi
done

echo "Build finished. dist/ is ready."
