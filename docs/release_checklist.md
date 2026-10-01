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
- [x] 新标题页显示操作说明，开始按钮与 Enter 均可进入关卡。
- [x] 暂停菜单支持 Escape/P、继续、重开、返回标题。
- [x] 暂停时游戏与倒计时冻结，音量滑块控制并保存 Master 音量。
- [x] 五张地图通过出口串联；生命值和总计时继承，每关卷轴计数重置。
- [x] 远程敌人会保持距离并发射伤害玩家的弹体，玩家可以近战击败它。
- [x] 胜负结算时清除仍在场的敌人弹体。
- [x] 阶段 9/10 headless 行为测试与两关通关回归通过。
- [x] 第二至第四关出口依次进入后续地图；共享生命/总计时，最终胜利只在第五关出口触发。
- [x] 阶段 11 headless 行为测试覆盖三关切换、入口位置、卷轴重置和最终胜利。
- [x] 阶段 12 headless 行为测试覆盖四关切换、第四关入口、卷轴重置和最终胜利。
- [x] 阶段 13 headless 行为测试覆盖五关切换、第五关入口、卷轴重置和最终胜利。
- [x] 第一至第五关出口提示统一使用中文字体 fallback，中文缺字回归通过。
- [x] Chromium 死亡流程复测通过；修复死亡帧碰撞监测错误，控制台错误为 0。
- [x] Web/macOS 重新导出并通过 ZIP 完整性检查，macOS 签名与 Universal 2 启动验证通过。
- [x] Web 实际画面确认标题页与暂停面板；浏览器控制台无错误。
- [x] 生成 630×500 itch.io 封面和最终游戏截图。
- [x] 导出 Universal macOS `.app` ZIP，并验证签名和无头启动。
- [x] 将 Noto Sans SC 的 SIL OFL 1.1 许可证打入 Web/macOS 包。
- [x] 音乐与音效文件解码、电平和 Godot 播放请求通过数字检查。

## 待完成

- [ ] 在扬声器或耳机上主观确认最终音乐与音效响度。
- [ ] 用户确认后提交并推送当前未提交改动。
- [ ] 用户完成 itch.io 登录和上传。

## 暂不计划

- 暂不购买 Apple Developer Program 会员或办理 macOS Developer ID 签名与 notarization；保留 ad-hoc macOS 包，优先免费发布 Web 版。

## 当前阻塞

Web/macOS 候选包已包含第五张地图；完整 Chromium 路线仍需实际抵达第五关验证。未自动上传或提交推送。macOS 包是 ad-hoc 签名、未 notarize。
