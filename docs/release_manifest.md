# 发布候选清单

- 验证日期：2026-10-03
- Godot：`4.7.2.stable.steam.ed1daf0bf`
- 目标：itch.io Web 上传包
- 本次内容：阶段 18（手柄、动画、震屏、暂停重开）+ 阶段 19（中英双语界面与语言切换 + 英文 HUD 布局修正）

## Web 候选包

- 文件：`release/ninja-night-scroll-web.zip`
- 内容：`index.html`、WASM、JavaScript、PCK、音频 worklet 和图标资源。
- SHA-256：`5cca5b87f53653c0cb55905e29c97d621e29c21fcdca3ba22c140dd001c9f69c`
- 校验：`unzip -t` 通过。
- PCK：8,735,072 字节，含五张地图、最终 Boss、手里剑、回血补给、远程敌人/弹体、Web 自动测试桥接、Noto Sans SC 和 OFL 1.1；导出过滤掉 godot-ai 插件、测试脚本和发布文档。
- 浏览器冒烟：真实 Chromium（headless，英文系统语言）加载 `index.html`，标题页完整渲染英文界面（标题、操作说明、Start Game、右下角中文切换按钮），0 个页面错误。

## 运行验证

- 19 个 `tests/*_test.gd` 全部通过（含 localization_test 与阶段 18 的输入动作、暂停重开、第二关出生点测试）；主场景 headless 冒烟通过。
- GitHub Actions workflow（`.github/workflows/tests.yml`）在 push/PR 时安装官方 Godot 4.7.2 并跑全量测试。
- 2026-10-03 包尚未重跑 Web `?playtest=autoplay` 五关桥接与人工键盘通关；上传 itch.io 后建议先自行试玩一局。历史记录：Web 自动桥接在 2026-10-02 包中完成五关，逐关遥测 `0.424s / 0.332s / 0.331s / 0.334s / 0.333s`，最终剩余 `178.171s`，五关均 `3/3` 卷轴、出口成功。该模式是测试桥接路径，不代表人工移动速度。

## macOS 候选包

- 文件：`release/macos/NinjaNightScroll.zip`
- 架构：Universal 2（x86_64 + arm64）。
- SHA-256：`f282f1a468ffe2f3d919c30b2c63ab058f9ce3623ca2f249353dc93c91a9d2e5`
- 校验：ZIP 可解压；`codesign --verify --deep --strict` 通过；可执行文件为 Universal 2（x86_64 + arm64）。
- 签名：ad-hoc；未使用 Developer ID，未 notarize。检查到 Keychain 中有 0 个有效签名身份、0 个 Developer ID Application 身份。
- 当前包包含第五关、最终 Boss、手里剑、回血补给、远程敌人与弹体，以及阶段 18 的动画、手柄和震屏改动；标题页、暂停流程和音量设置也已包含。

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

- 最终 Web 包已上传并公开发布：`https://ljh-snow.itch.io/ninja-night-scroll`。
- 用户确认其他电脑无需登录即可运行游戏、声音正常，并完成第五关胜利流程。
