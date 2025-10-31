#!/usr/bin/env bash
# 统一用 bash + 严格模式
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

# 需要处理的页面（可按需增减）
PAGES=(index.html book.html lesson.html)

# 你的底部块（尽量少用引号、避免转义麻烦）
read -r -d '' FOOTER_HTML <<'EOF'
<footer style="text-align:center;padding:16px 0;color:#666;font-size:14px;">
  牛爸小课堂 © 2025 ｜源码:Luzhenhua ｜Q邮：mylsm ｜<a href="/" style="color:#0b6cff;text-decoration:none;">返回首页</a>
</footer>
EOF

echo "Patching footer on pages: ${PAGES[*]}"

for page in "${PAGES[@]}"; do
  f="dist/$page"
  [ -f "$f" ] || continue

  # 1) 若已有 <footer>…</footer>，直接整体替换（大小写不敏感）
  # 2) 否则，把 FOOTER_HTML 插入到 </body> 之前（大小写不敏感）
  if grep -qi "<footer" "$f"; then
    # 使用 perl 做多行/大小写不敏感替换，兼容性更好
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
