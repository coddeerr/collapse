# Codex 项目规则

本项目的运行时美术资产必须通过本地 `agent-sprite-forge` 流程生成。

生成资产前必须读取：

- `D:\agent-sprite-forge\skills\generate2dsprite\SKILL.md`
- `D:\agent-sprite-forge\skills\generate2dmap\SKILL.md`

规则：

- 角色、工具、道具、建筑、作物、树木、特效使用 `generate2dsprite`。
- 可玩地图、地图层、碰撞、触发区、scene hooks 使用 `generate2dmap`。
- 概念图只能放在 `art/concepts/` 或 `art/style-exploration/`，不能直接作为运行时资产。
- 每次生成运行时资产，必须在 `art/production-runs/` 写生产记录。
- 没有生产记录的生成图，不算合格运行时资产。
- Godot 运行时代码不得依赖 `agent-sprite-forge`。
- 提交前运行 `godot_console.exe --headless --path . --quit-after 5`；新增图片时还要运行 `godot_console.exe --headless --path . --import`。

详细规则见：

- `docs/asset-pipeline-rules.md`
- `art/production-runs/README.md`
