# 调研与项目发现

## 2026-09-30

### 当前项目

- 当前文件夹是一个极简 Godot 项目。
- `project.godot` 已配置 Godot 4.7，主场景为 `res://node_2d.tscn`。
- 当前场景只有一个 `Node2D` 和一个图标精灵，适合从零建立原型。

### itch.io 素材

- 推荐主素材：`Ninja Adventure - Asset Pack`。
- 页面说明该素材包含角色、敌人、Boss、道具、地图瓦片、UI、特效、音效、音乐和 Godot 4 示例项目。
- 页面标注为 CC0，适合先做一个不需要额外授权处理的独立小游戏原型。
- 第一版不应直接覆盖素材包示例项目的 `project.godot`，应选择性复制素材并合并到当前项目。

### godot-ai

- `hi-godot/godot-ai` 是通过 MCP 连接 AI 客户端和正在运行的 Godot 编辑器的工具。
- 适合辅助创建节点、场景、脚本、UI、项目设置和重复性的编辑器操作。
- README 提到使用 Godot 4.7+、`uv/uvx` 和 MCP 客户端；当前项目版本配置与此要求一致。
- 使用时仍需在 Godot 中实际运行和检查生成结果，避免把未验证的脚本或场景结构直接当成完成品。

### 设计结论

- 俯视角单地图收集逃脱比完整 RPG、平台跳跃或随机 Roguelike 更适合当前空项目。
- 目标应限制为：1 张地图、1 个玩家、3 种敌人以内、3 个卷轴、1 个出口、3 分钟计时。
- 先完成可玩的核心循环，再补充 Boss、更多地图和装饰内容。

## 外部参考

- itch.io：独立游戏和游戏素材发布平台。
- `Ninja Adventure - Asset Pack`：主要美术和音频素材来源。
- `hi-godot/godot-ai`：Godot 编辑器 AI 操作与 MCP 集成参考。

外部页面内容只作为素材授权和工具能力的参考，具体实现以当前项目文件和实际运行结果为准。

### 阶段 1 本地验证

- 已从素材作者公开的 `pixel-boy/NinjaAdventure` 仓库获取阶段 1 所需资源，固定来源提交为 `6ac78232d5aedcc85ce5f27d060ea92366f7c24a`。
- 已复制 `godot-ai` 插件到 `addons/godot_ai/`，保留插件自带的 `LICENSE`。
- 已完成主场景和资源文件的存在性检查。
- 已在 2026-09-30 初始化 Git 仓库，当前分支为 `main`，尚未创建提交。
- 初始检查时当前 shell 找不到 Godot CLI；后续定位到 Steam 安装路径并使用 Godot 4.7.2 完成验证。

### 阶段 2 验证

- 实际使用的 Godot 版本为 `4.7.2.stable.steam.ed1daf0bf`。
- 首次直接运行主场景时出现 `No loader found for resource`，原因是新增资源尚未完成 Godot 导入，编辑器进程过早退出。
- 延长 headless 编辑器扫描后，PNG、TTF 和 OGG 资源均完成导入。
- 重新运行主场景 20 帧，进程正常退出且没有解析或运行错误。
- 阶段 2 的行为输入仍需在交互式编辑器中手动确认按键反馈；当前 headless 验证覆盖了场景加载、脚本注册和资源导入。

### 阶段 3 实现与验证

- `ChasingEnemy` 使用 `CharacterBody2D` 追踪 `player` 组中的玩家，并通过接触距离和冷却时间造成伤害。
- 玩家生命值从 3 开始，受伤后有短暂无敌时间；攻击区域可以对碰撞层 2 的敌人调用 `take_damage`。
- `ScrollPickup` 使用 `Area2D.body_entered`，通过 `collected_once` 保证同一个卷轴只计数一次。
- 第一次绿测发现 `main.gd` 直接使用新全局类 `ScrollPickup`，在未刷新类缓存的 headless 进程中无法编译；改为 `Area2D` + 信号连接后通过。
- 阶段 3 冒烟测试和主场景 30 帧 headless 运行均通过。

### 输入无响应诊断

- 用户截图中 `输入` 模式已经高亮，不能再把问题归因于 Godot 嵌入式输入模式。
- 截图中敌人已经与玩家重叠，HUD 显示生命值为 `0 / 3`。
- 运行状态测试在 360 个物理帧后复现 `health=0`、`dead=true`；玩家死亡后脚本主动停止移动和攻击。
- 当前版本没有死亡后的自动重开或明显的死亡覆盖层；重新运行主场景后应在敌人接近前立即移动。

### 阶段 4 实现与验证

- 倒计时从 180 秒开始，HUD 显示 `时间 03:00`，归零后进入失败状态。
- 玩家死亡和倒计时结束都显示结果覆盖层；覆盖层提示按 `R` 重新开始。
- `SceneTree.reload_current_scene()` 的实际重开路径已通过 headless 测试。
- 出口 `Area2D` 只有在收集 3 个卷轴后才会触发胜利；未收集完成时保留目标提示。
- 敌人出生点已从玩家右侧近距离位置移到右下区域，降低刚开局就被击败的误判。

### 中文字体显示诊断

- `assets/ui/font_normal.ttf` 的字体名称为 Ninja Adventure Regular，覆盖英文像素字形但不覆盖项目使用的中文字符。
- Godot 对缺失字形显示方框，截图中的符号不是二进制数。
- 已加入 `assets/ui/NotoSansSC-Regular.ttf` 作为本地 CJK fallback，保留原像素字体的英文显示。
- Godot 4.7.2 导入无错误，fallback 资源数量为 1，阶段 4 回归测试通过。

### 阶段 5 实现与验证

- 背景音乐使用素材包中的 `theme_plain.ogg`；攻击、拾取、受伤和胜利音效为本地生成的短 PCM WAV，不引入额外音频授权。
- `AudioStreamPlayer` 节点由 `scripts/main.gd` 根据攻击、拾取、受伤和胜负信号触发。
- `FlashOverlay` 使用 Tween 做短暂颜色闪屏，关卡加入草、罐子和箱子装饰。
- Steam Godot headless 环境的显示服务名为 `headless`，已跳过实际音频播放并在退出时释放音乐 stream，避免测试资源泄漏。
- 阶段 5 冒烟测试、阶段 4 回归测试和主场景 headless 启动均通过。

### 过夜计划第一轮

- 已创建根目录 README、发布清单和 itch.io 页面草稿。
- 完整回归覆盖字体 fallback、阶段 3、阶段 4、阶段 5、R 重开、主场景启动和资产导入。
- 未发现 `.env`、证书、私钥等敏感文件。
- 项目目录约 30 MB，`assets/` 约 11 MB，`addons/godot_ai/` 约 3 MB。
- 当前没有 `export_presets.cfg`，也没有检测到 Godot 4.7.2 匹配的 Export Templates；不能生成真实 itch.io 平台包，需用户在 Godot 编辑器中安装模板后继续。
- 官方 4.7.2 Export Templates 已安装到 Godot 用户目录中的 `4.7.2.stable`。
- Web 导出成功，发布包为 `release/ninja-night-scroll-web.zip`，SHA-256 为 `379e7c7743b536bc44b665c07acf73746dcdfebd37cef5f731394e85720f1836`。
- Chromium/WebGL 实测加载了 `index.html`、WASM、PCK、音频 worklet 和图标资源，控制台无错误。
- Web/music 与 macOS build 的首次发布包已清理，当前最终 SHA-256 记录在 `docs/release_manifest.md`。

### 音频与签名复核（2026-10-01）

- 最初四个生成 WAV 峰值约 `-30 dBFS`；源文件增益提高后峰值为 `-12 dBFS`。经播放器增益后，攻击峰值约 `-16 dBFS`，拾取/受伤/胜利约 `-14 dBFS`。
- `theme_plain.ogg` 解码后 mean `-21.4 dBFS`、peak `-4 dBFS`；音乐播放器由 `-14 dB` 调至 `-9 dB`，数字混音测试通过。
- Godot 载入并启动五个 AudioStreamPlayer 的测试通过；AudioEffectRecord 在 headless 环境对 OGG 输出不稳定，因此不能替代实体扬声器试听。
- Keychain 中有效代码签名身份数为 0，Developer ID Application 身份数为 0；当前 macOS 包只有 ad-hoc 签名且未 notarize。
- 音量调整后 Web/macOS 均重新导出，当前包哈希见 `docs/release_manifest.md`。

### 标题页与暂停菜单（2026-10-01）

- 项目入口改为 `res://scenes/title_screen.tscn`；标题按钮与 Enter 均能进入 `main.tscn`。
- 主场景根节点以 Always 模式处理暂停输入，Playfield/HUD/Audio 以 Pausable 模式冻结；PauseOverlay 使用 Always 保持按钮和滑块可操作。
- Escape/P 切换暂停；继续、暂停重开、返回标题均已自动化验证；暂停期间倒计时不变。
- Master Slider 使用 `AudioServer.set_bus_volume_linear`，通过 `ConfigFile` 保存到 `user://settings.cfg`。
- 浏览器截图确认标题说明与暂停面板布局；Web Console 无错误。
- 为 R 重开调整输入处理顺序，避免场景卸载后访问旧 Viewport。
