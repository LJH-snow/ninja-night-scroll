# 忍者夜行：三分钟夺卷

一个使用 Godot 4.7 制作的俯视角 2D 小游戏。玩家控制忍者闯过四张相连地图，每关收集 3 个卷轴并抵达出口；四关共用 3 分钟和同一条生命值。敌人会追击或保持距离发射弹体，玩家可以躲避弹体并用近战反击。

## 操作

- `WASD` 或方向键：移动
- `Space`：攻击
- `Esc` / `P`：暂停或继续
- 暂停菜单中的滑块：调节并保存总音量
- `R`：胜利或失败后重新开始

## 运行

1. 使用 Godot 4.7.x 打开项目。
2. 按 F5 运行项目，标题页会先显示操作说明。
3. 如果使用编辑器嵌入运行窗口，先切换到顶部的 `输入` 模式，再点击游戏画面。

## 项目结构

- `scenes/`：四张地图、近战/远程敌人、敌人弹体、玩家、卷轴和出口。
- `scenes/title_screen.tscn`：标题页、角色展示和操作说明。
- `scripts/`：移动、战斗、敌人、收集、倒计时和胜负逻辑。
- `assets/`：角色、地图、UI、字体、音频和装饰。
- `docs/`：游戏计划、发布清单、itch.io 文案和授权记录。

## 发布状态

阶段 12 的第四关与四地图流程已完成；Web/macOS 发布候选已重新导出：

- itch.io Web 包：`release/ninja-night-scroll-web.zip`
- macOS Universal 2 包：`release/macos/NinjaNightScroll.zip`
- 页面封面：`release/itch-cover.png`

macOS 包当前为 ad-hoc 签名，尚未 Developer ID 签名或 notarize；本机 Keychain 未检测到 Developer ID Application 身份。项目尚未自动上传 itch.io。

素材和字体授权记录见 `docs/asset_licenses.md`。
