# DangerSnake — itch.io WebGL upload

1. In Unity: **DangerSnake → Build → WebGL (itch.io)**
2. Wait for `Builds/WebGL/` (contains `index.html`, `Build/`, `TemplateData/`).
3. Zip the **contents** of `Builds/WebGL` (or the folder itself — itch accepts both if `index.html` is at zip root).
4. On [itch.io](https://itch.io): create game → **Uploads** → upload zip.
5. Set **Kind of project**: *HTML*
6. Enable **This file will be played in the browser**
7. Embed size suggestion: **960 × 600** (matches Player Settings Web defaults)
8. Optional: add keyboard note — *Arrow keys / WASD*

Compression: project uses **Brotli** with decompression fallback for hosts that do not serve `.br` correctly.
