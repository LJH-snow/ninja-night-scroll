# Ninja Night Scroll: Three-Minute Escape

A top-down 2D action game made with Godot 4.7. Guide a ninja through five connected maps, collect three scrolls on each map, and reach the exit. All five stages share one three-minute timer and one health bar. Use sword knockback, shurikens, and green health pickups to survive chasing and ranged enemies before facing the final boss.

## Controls

- `WASD` or Arrow Keys: Move
- `Space`: Sword attack and knockback
- `Shift`: Throw shuriken
- `Esc` / `P`: Pause or resume
- Pause menu slider: Adjust and save the master volume
- `R`: Restart after victory or defeat

## Running

1. Open the project with Godot 4.7.x.
2. Press F5 to run the project; the title screen displays the controls first.
3. If using the embedded editor game window, switch the top toolbar to `输入` (Input) mode and click the game view.

## Project Structure

- `scenes/`: Five maps, melee/ranged enemies, enemy projectiles, the player, scrolls, health pickups, and exits.
- `scenes/title_screen.tscn`: Title screen, character showcase, and controls.
- `scripts/`: Movement, combat, enemies, pickups, countdown, and result logic.
- `assets/`: Characters, maps, UI, fonts, audio, and decorations.
- `docs/`: Game plan, release checklist, itch.io copy, and license records.

## Release Status

The game is published on itch.io: <https://ljh-snow.itch.io/ninja-night-scroll>

- itch.io Web build: `release/ninja-night-scroll-web.zip`
- Universal 2 macOS build: `release/macos/NinjaNightScroll.zip`
- Page cover: `release/itch-cover.png`
- 15 Godot tests pass, and the Web autoplay bridge completes all five levels.

The macOS build is ad-hoc signed and has not been signed with Developer ID or notarized.
See `docs/asset_licenses.md` for the asset and font license records.

---

# 忍者夜行：三分钟夺卷

一个使用 Godot 4.7 制作的俯视角 2D 小游戏。玩家控制忍者闯过五张相连地图，每关收集 3 个卷轴并抵达出口；五关共用 3 分钟和同一条生命值。第五关有最终 Boss，必须击败 Boss 后才能完成任务。玩家可以用短剑击退敌人、发射手里剑攻击远处目标，并在地图中寻找绿色回血补给。

## 操作

- `WASD` 或方向键：移动
- `Space`：攻击
- `Shift`：发射手里剑
- `Esc` / `P`：暂停或继续
- 暂停菜单中的滑块：调节并保存总音量
- `R`：胜利或失败后重新开始

## 运行

1. 使用 Godot 4.7.x 打开项目。
2. 按 F5 运行项目，标题页会先显示操作说明。
3. 如果使用编辑器嵌入运行窗口，先切换到顶部的 `输入` 模式，再点击游戏画面。

## 项目结构

- `scenes/`：五张地图、近战/远程敌人、敌人弹体、玩家、卷轴和出口。
- `scenes/title_screen.tscn`：标题页、角色展示和操作说明。
- `scripts/`：移动、战斗、敌人、收集、倒计时和胜负逻辑。
- `assets/`：角色、地图、UI、字体、音频和装饰。
- `docs/`：游戏计划、发布清单、itch.io 文案和授权记录。

## 发布状态

阶段 13 的第五关与五地图流程已完成；Web/macOS 发布候选已重新导出：

- itch.io Web 包：`release/ninja-night-scroll-web.zip`
- macOS Universal 2 包：`release/macos/NinjaNightScroll.zip`
- 页面封面：`release/itch-cover.png`

macOS 包当前为 ad-hoc 签名，尚未 Developer ID 签名或 notarize；本机 Keychain 未检测到 Developer ID Application 身份。项目尚未自动上传 itch.io。

素材和字体授权记录见 `docs/asset_licenses.md`。
