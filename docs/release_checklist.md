# 发布检查清单

## 已完成

- [x] 主场景可以启动。
- [x] WASD/方向键移动和 Space 攻击可用。
- [x] 敌人追踪、生命值、无敌帧和死亡提示可用。
- [x] 3 个卷轴、出口、180 秒倒计时和胜负覆盖层可用。
- [x] `R` 键可以重新开始当前场景。
- [x] 中文字体、背景音乐、音效和关卡装饰已接入。
- [x] 素材授权记录已整理到 `docs/asset_licenses.md`。
- [x] 阶段 3、阶段 4、阶段 5 headless 回归测试通过。
- [x] 安装与 Godot `4.7.2` 匹配的 macOS/Web Export Templates。
- [x] 创建 Web `export_presets.cfg`。
- [x] 生成并校验 `release/ninja-night-scroll-web.zip`。
- [x] 在真实 Chromium/WebGL 中打开 Web 包。
- [x] Web 版实测方向键移动、Space 攻击、R 重开和中文 HUD。
- [x] 生成 630×500 itch.io 封面和最终游戏截图。
- [x] 导出 Universal macOS `.app` ZIP，并验证签名和无头启动。
- [x] 将 Noto Sans SC 的 SIL OFL 1.1 许可证打入 Web/macOS 包。
- [x] 音乐与音效文件解码、电平和 Godot 播放请求通过数字检查。

## 待完成

- [ ] 在扬声器或耳机上主观确认最终音乐与音效响度。
- [ ] 对 macOS `.app` 做 Developer ID 签名和 notarization（可选，需要 Apple 开发者凭据）。
- [ ] 用户确认后提交并推送当前未提交改动。
- [ ] 用户完成 itch.io 登录和上传。

## 当前阻塞

Web 与 macOS 发布候选、封面及截图均已生成；尚未自动上传或提交推送。macOS 包是 ad-hoc 签名、未 notarize。
