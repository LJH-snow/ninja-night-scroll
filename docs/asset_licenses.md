# 素材与授权记录

## Ninja Adventure - Asset Pack

- 来源：itch.io 上的 Ninja Adventure - Asset Pack。
- 用途：本项目的角色、敌人、地图瓦片、UI 和音频原型。
- 页面声明：Creative Commons Zero（CC0）。
- 本地来源提交：`pixel-boy/NinjaAdventure`，提交 `6ac78232d5aedcc85ce5f27d060ea92366f7c24a`。
- 本项目只复制了阶段 1 所需的少量文件，没有覆盖素材示例项目的工程配置。

## Godot AI

- 来源：`hi-godot/godot-ai`。
- 用途：Godot 编辑器中的 MCP/AI 辅助工具。
- 插件目录：`addons/godot_ai/`。
- 插件自带许可证文件保留在 `addons/godot_ai/LICENSE`。

发布前再次检查外部素材页面和仓库的授权说明，并把本文件随项目保留。

## 中文字体回退

- 当前 UI 保留 Ninja Adventure 像素字体作为主字体。
- `assets/ui/NotoSansSC-Regular.ttf` 为缺失的中文字符提供本地回退。
- 字体来源：Google Fonts 的 Noto Sans SC，许可为 SIL Open Font License 1.1。
- 完整许可证副本：`assets/ui/OFL.txt`，并通过 Web/macOS 导出预设打入发行包。
- 本地字体随项目打包，避免依赖开发机系统字体；发布前保留来源和许可记录。

## 音频与装饰

- `theme_plain.ogg` 和草、罐子、箱子来自 Ninja Adventure - Asset Pack，授权记录见上文。
- `attack.wav`、`pickup.wav`、`hurt.wav`、`victory.wav` 是本项目使用 `ffmpeg` 生成的短提示音，不使用外部采样。
