# NCE-Flow Netlify Starter (GitHub → Netlify)

> **零门槛方案**：本仓库在 Netlify 构建时自动从上游下载最新的 **NCE-Flow** 源码，移除上游 `CNAME`，并注入缓存头与 `404.html`，最终产物发布在 `dist/`。你无需手动拷贝大文件。

## 使用步骤（新手友好）

1. 把本项目上传到你的 GitHub（或直接创建新仓库并上传这些文件）。
2. 打开 Netlify → **Add new site → Import from Git** → 选择你的仓库。
3. 配置：
   - **Build command**：`bash fetch.sh`
   - **Publish directory**：`dist`
4. 点击 **Deploy**。构建过程会自动：下载上游源码 → 解压 → 删除 `CNAME` → 写入 `_headers` 与 `404.html` → 发布。

> 如需本地预览，可在 Windows PowerShell 运行：`./fetch.ps1`，然后用任意静态服务器打开 `dist/`（例如 `python -m http.server 8000` 后访问 `http://localhost:8000` 并将站点根指到 `dist` 目录）。

## 注意
- 本项目遵循上游项目的内容与版权说明，仅供**个人学习**使用。请避免公开传播课程音频等受版权保护的内容。
- 如果未来上游仓库的默认分支不是 `main`，或改了结构，修改 `fetch.sh` / `fetch.ps1` 中的下载地址与展开目录名即可。
