# 发布候选清单

- 验证日期：2026-10-01
- Godot：`4.7.2.stable.steam.ed1daf0bf`
- 目标：itch.io Web 上传包

## Web 候选包

- 文件：`release/ninja-night-scroll-web.zip`
- 内容：`index.html`、WASM、JavaScript、PCK、音频 worklet 和图标资源。
- SHA-256：`92f0548328071595a540753ca51c0e4c282091f5f2e759451691845860cdb084`
- 校验：`unzip -t` 通过。
- PCK：约 8.3 MB，包含 Noto Sans SC 和 OFL 1.1；不含 godot-ai 插件脚本和发布文档。

## 运行验证

- Godot Web 导出命令成功完成。
- 通过临时 HTTP 服务器在真实 Chromium/WebGL 中打开。
- 中文标题、HUD、关卡装饰和胜负界面正常显示。
- 浏览器控制台只有 Godot 正常启动日志，没有错误。
- Web 输入已实测：方向键移动、Space 攻击、`R` 重开，并看到重开后 `03:00`、`3/3` 生命。
- 验证截图：`output/playwright/restart-immediate.png`、`output/playwright/web-movement-check.png`、`output/playwright/web-attack-check.png`。

## macOS 候选包

- 文件：`release/macos/NinjaNightScroll.zip`
- 架构：Universal 2（x86_64 + arm64）。
- SHA-256：`5060cd5f106cdc246b5b87e7d8639a8849ca2e74bc6c61838cf336064044737b`
- 校验：ZIP 可解压；`codesign --verify --deep --strict` 通过；包内可执行文件 `--headless --quit-after 30` 无错误启动。
- 签名：ad-hoc；未使用 Developer ID，未 notarize。检查到 Keychain 中有 0 个有效签名身份、0 个 Developer ID Application 身份。

## 音频检查

- OGG 背景音乐可解码；源文件 peak `-4 dBFS`、mean `-21.4 dBFS`，播放器设为 `-9 dB`。
- 四个 WAV 音效可解码且非静音，源 peak 均为 `-12 dBFS`；播放器增益为 `-4 dB`（攻击）和 `-2 dB`（拾取/受伤/胜利）。
- Godot 中五个 `AudioStreamPlayer` 的资源和播放请求测试通过。
- 尚未在实体扬声器/耳机上主观试听，最终响度仍建议用户确认。

## itch.io 图片

- 封面：`release/itch-cover.png`，630×500 PNG。
- 封面源文件：`docs/itch_cover.svg`。
- 可用游戏截图：`output/playwright/restart-immediate.png`。

## 上传边界

- 包已准备好，但没有自动上传 itch.io。
- 上传时选择 `release/ninja-night-scroll-web.zip`，并按 `docs/itch_page_draft.md` 填写页面。
