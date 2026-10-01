# 进度记录

## 2026-09-30

- 已检查当前项目目录，确认是 Godot 4.7 极简 2D 项目。
- 已确定游戏方向：俯视角忍者收集逃脱小游戏。
- 已确定主要素材：itch.io 的 Ninja Adventure - Asset Pack。
- 已创建 `docs/` 文档目录。
- 已创建 `docs/game_plan.md`、`task_plan.md`、`findings.md` 和本文件。
- 已创建 `assets/`、`scenes/` 和 `addons/` 目录，并复制阶段 1 所需的角色、敌人、地图、UI、字体和音乐素材。
- 已接入 `godot-ai` 插件文件，并启用项目插件配置。
- 已将主场景切换到 `res://scenes/main.tscn`，建立原型 HUD、角色/敌人预览和出口区域。
- 已通过必需文件存在性检查。
- 初始阶段未执行 Git 差异检查；Git 初始化后已在后续修改中执行。
- 初始阶段当前 shell 找不到 Godot CLI，但后续已定位 Steam 安装路径。
- 已初始化 Git 仓库，当前分支为 `main`，未创建初始提交。
- 用户已确认创建首个 Git 提交，当前阶段文件将纳入该提交。
- 已创建 `scripts/player.gd`，实现 WASD/方向键移动、朝向、攻击冷却和临时攻击区域。
- 已创建 `scenes/player.tscn`，加入 `CharacterBody2D`、碰撞形状、攻击 `Area2D` 和攻击可视化。
- 已在 `scenes/main.tscn` 中加入四面 `StaticBody2D` 边界，并替换为玩家场景实例。
- 阶段 2 静态检查通过；真正的 Godot 运行验证待安装/打开非 Steam 快捷方式的 Godot 编辑器。
- 已使用 Steam 安装的 Godot 4.7.2 完成资产导入和主场景无界面运行验证。
- 首次运行的资源加载错误来自资产导入尚未完成；延长编辑器扫描后重新运行通过。
- 阶段 2 完成：玩家移动、四面边界碰撞和 Space 临时攻击区域已接入。
- 已创建 `scripts/enemy.gd` 和 `scenes/enemy.tscn`，实现敌人追踪、接触伤害、生命值和受击消失。
- 已创建 `scripts/scroll_pickup.gd` 和 `scenes/scroll_pickup.tscn`，实现卷轴拾取信号和单次收集。
- 已创建 `scripts/main.gd`，将玩家生命值、敌人和 3 个卷轴接入主场景 HUD。
- 阶段 3 红测按预期捕捉到缺失场景、玩家生命值和玩家分组行为。
- 阶段 3 绿测通过：主场景加载、敌人靠近玩家、玩家受伤与无敌帧、卷轴单次计数。
- 完整主场景 headless 运行 30 帧通过，无解析或运行错误。
- 修复了 `main.gd` 对新全局类缓存的加载顺序依赖，改为基于 `Area2D` 信号连接卷轴。
- 输入问题诊断：截图中 `输入` 模式已开启，但敌人已贴近玩家；运行 360 个物理帧后玩家状态为 `health=0`、`dead=true`。
- 玩家死亡后 `scripts/player.gd` 会将速度清零并停止处理移动，因此表现为键盘无响应。
- 已创建 `scripts/exit_zone.gd` 和 `scenes/exit_zone.tscn`，实现出口区域检测。
- `scripts/main.gd` 已加入 180 秒倒计时、超时失败、死亡提示、出口胜利和 `R` 键重新加载当前场景。
- `scenes/main.tscn` 已加入结果覆盖层、计时/生命 HUD、出口实例和远距离敌人初始位置。
- 阶段 4 红测按预期发现缺失出口、覆盖层、倒计时和远距离出生点。
- 阶段 4 绿测通过：倒计时初始化、死亡失败、超时失败、出口胜利和覆盖层文案。
- `R` 重开测试通过，完整主场景 headless 启动 30 帧通过。
- 阶段 4 完成：死亡提示、R 重开、倒计时、出口和胜负结算已接入。
- 已接入 `theme_plain.ogg` 背景音乐和攻击、拾取、受伤、胜利四个短音效。
- 已加入受击/拾取/胜负闪屏反馈，并复制草、罐子和箱子装饰资源完善首个关卡。
- 阶段 5 红测按预期发现缺失音频、闪屏和装饰节点；修正测试路径后全部通过。
- 阶段 5 回归测试通过，headless 主场景无音频资源泄漏警告。
- 修复 Steam Godot headless 环境的音频播放条件，交互式运行仍保留音乐和音效。
- 阶段 5 完成：音频、反馈特效和首个完整关卡已接入。
- 中文显示问题已定位：`font_normal.ttf` 是不含 CJK 字形的像素字体，方框是缺字占位符，不是二进制。
- 已加入 `assets/ui/NotoSansSC-Regular.ttf`，并在 `scripts/main.gd` 中作为像素字体的中文 fallback。
- 字体导入无错误，fallback 测试通过，阶段 4 回归测试和主场景启动测试继续通过。
- 已建立过夜开发计划 `docs/overnight_plan.md`，边界是不自动上传、不创建后台任务、不自动提交推送。
- 已创建根目录 `README.md`、`docs/release_checklist.md` 和 `docs/itch_page_draft.md`。
- 已确认 Godot `4.7.2.stable.steam.ed1daf0bf` 可运行项目，但当前没有 `export_presets.cfg` 和匹配的 Export Templates。
- 阶段 6 发布文档部分完成；导出包生成等待用户安装或提供对应导出模板。
- 已从官方 4.7.2 模板包安装 macOS 和 Web Export Templates。
- 已创建 `export_presets.cfg` 的 Web 预设并成功导出 `release/web/`。
- 已生成 `release/ninja-night-scroll-web.zip`，`unzip -t` 通过，SHA-256 已记录到 `docs/release_manifest.md`。
- 已通过真实 Chromium/WebGL 打开 Web 包，中文界面、HUD、装饰和 Godot 启动日志验证通过。
- 已关闭临时 HTTP 服务器和浏览器，没有留下持续运行的后台进程。
- 继续完善发布候选：增加 Universal 2 macOS ZIP，修正独立包字体依赖，并验证导出 `.app` 的无头启动。
- Web 版浏览器输入实测通过：方向键移动、Space 攻击、`R` 重开（立即截帧显示计时 `03:00`、生命 `3/3`）。
- 生成 630×500 封面 `release/itch-cover.png`；添加 Noto Sans SC 完整 OFL 许可证并确认写入 Web/macOS PCK。
- 清理导出内容：PCK 从误含全部编辑器插件脚本降到约 8.3 MB，仅有编辑器插件 manifest 路径字符串，不含插件脚本或文档。
- macOS app 验证为 Universal 2（x86_64 + arm64），ad-hoc 签名验证通过；未 notarize。
- 用户同意继续检查音效与 macOS 签名。四个 WAV 源文件峰值由约 `-30 dBFS` 调整为 `-12 dBFS`，播放器端峰值约 `-16 dBFS`（攻击）和 `-14 dBFS`（其余短音效）。
- 背景音乐源为 peak `-4 dBFS` / mean `-21.4 dBFS`；音乐总线衰减从 `-14 dB` 调整至 `-9 dB`，混音电平测试通过。
- Godot AudioStreamPlayer 资源和播放请求测试通过；headless 下 AudioEffectRecord 对 OGG 不稳定，因此没有把它当作音乐可听性的证据，实体扬声器试听仍待确认。
- Keychain 检查到 0 个有效代码签名身份和 0 个 Developer ID Application 身份；notarytool 可用，但当前无法生成 Developer ID 签名或 notarize。
- 重新导出音量修正后的 Web/macOS 包，ZIP 校验通过；最终哈希见 `docs/release_manifest.md`。
- 背景音乐实际衰减测试确认 `-9 dB` 混音阈值通过；四个短音效峰值和播放器增益达到约 `-14` 至 `-16 dBFS`。
- 最新 macOS ZIP 再次通过签名校验和无头启动；Web ZIP、macOS ZIP、封面哈希已与清单核对一致。

## 2026-10-01 发布候选复核

- Web ZIP SHA-256：`6603e0dcbfb0b031c2ad6a6945f04ed8d11c130cf121316832bcbdf7bb10af40`；`unzip -t` 通过。
- macOS Universal ZIP SHA-256：`ce9852ba20a011706d03ad5cf2c5b36f6a90d41db4e1bb098e89b86264afd3c3`；`codesign --verify --deep --strict` 与 app 无头启动通过。
- 封面 `release/itch-cover.png` 为 630×500 PNG，SHA-256：`bc10624dcbcbc88791f9e23c25b7de766546d372f3d5ad8fec4d51e50f63260f`。
- 复跑字体、阶段 3、4、5、重开和主场景测试均通过。
- Chromium/WebGL 实测方向键移动、Space 攻击和 `R` 重开；浏览器采用静音模式，未声称已确认音量。
- 未上传 itch.io，未提交或推送 Git；未留下本地服务器进程。

### 后续动作

- 用户可手动试听并上传 Web 包；如需上架 macOS 下载，需先配置 Developer ID Application 证书并完成 Apple notarization。
- Git 改动仍未提交或推送。
