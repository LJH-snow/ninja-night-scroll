# 发布候选清单

- 验证日期：2026-10-01
- Godot：`4.7.2.stable.steam.ed1daf0bf`
- 目标：itch.io Web 上传包

## Web 候选包

- 文件：`release/ninja-night-scroll-web.zip`
- 内容：`index.html`、WASM、JavaScript、PCK、音频 worklet 和图标资源。
- SHA-256：`fcc5a97359d5ff71dfe9720786d2db1c84190aa0a2967db2f77775dc5116dc59`
- 校验：`unzip -t` 通过。
- PCK：8,709,888 字节，含五张地图、最终 Boss、远程敌人/弹体、Noto Sans SC 和 OFL 1.1；导出过滤掉 godot-ai 插件、测试脚本和发布文档。

## 运行验证

- Godot Web 导出成功，当前 ZIP 完整性检查通过；阶段 10/11/12 Godot 行为测试与标题场景 headless 启动通过。
- Chromium/WebGL 已验证当前包标题加载、真实键盘移动、卷轴计数和死亡覆盖层；修复死亡帧碰撞监测后，死亡复现流程控制台错误为 0。
- 完整浏览器路线尚未抵达第五关：第一关敌人会在路线中击败玩家；第五关切换与最终胜利已由 `tests/level_five_test.gd` 的真实场景行为测试覆盖。
- 上一版已有的输入、标题、暂停和音量行为测试结果仍记录在旧截图中：`output/playwright/title-screen.png`、`output/playwright/pause-menu.png`、`output/playwright/title-enter-start.png`。

## macOS 候选包

- 文件：`release/macos/NinjaNightScroll.zip`
- 架构：Universal 2（x86_64 + arm64）。
- SHA-256：`05f9f1a677db0baaf78740cc894ba59afcd1be55802f93216a39de4848a9af2c`
- 校验：ZIP 可解压；`codesign --verify --deep --strict` 通过；Universal 2（x86_64 + arm64）可执行文件 `--headless --quit-after 30` 无错误启动。
- 签名：ad-hoc；未使用 Developer ID，未 notarize。检查到 Keychain 中有 0 个有效签名身份、0 个 Developer ID Application 身份。
- 当前包包含第五关、最终 Boss、远程敌人与弹体；标题页、暂停流程和音量设置也已包含。

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
