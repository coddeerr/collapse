# 美术资产生产规则

本文件保存详细规则。根目录 `AGENTS.md` 只保留每次会话必须加载的短规则。

## 强制原则

运行时美术资产必须通过本地 `agent-sprite-forge` 流程生成。

本地 skill 来源：

```text
D:\agent-sprite-forge\skills\generate2dsprite\SKILL.md
D:\agent-sprite-forge\skills\generate2dmap\SKILL.md
```

概念图可以自由探索，但只能放在：

```text
art/concepts/
art/style-exploration/
```

概念图不能直接作为最终运行时资产。

## Skill 选择

使用 `generate2dsprite`：

- 玩家角色、NPC、怪物
- 工具、道具、建筑、作物、树木
- 投射物、法术、命中特效
- 动画 sheet

使用 `generate2dmap`：

- 可玩地图
- 分层 raster 地图
- 基础地形层
- 道具摆放
- 碰撞、触发区、scene hooks
- 地图预览

一个需求同时包含地图和 sprite 时，两个 skill 都要使用，输出保持分离。

## 生产记录

每次生成运行时资产，都必须在：

```text
art/production-runs/
```

创建生产记录，至少包含：

- 日期和目的
- 使用的 skill
- skill 源路径
- 完整 prompt
- 原始输出路径
- 后处理命令
- 最终输出路径
- QC 结果
- Godot 接入说明

没有生产记录的生成图，不算合格运行时资产。

## `generate2dsprite` 要点

- 原始视觉资产必须来自 Image2 / 图像生成。
- 不得用程序绘制替代真实 sprite。
- 默认使用纯 `#FF00FF` chroma-key 背景。
- controllable hero / 主角的多动作资产，应先分动作生成 sheet。
- 主角攻击、射击、施法身体动作默认不包含大范围特效。
- 宽幅刀光、弹道、命中特效应作为独立 `fx` / `projectile` / `impact` sheet。
- 角色动画不要直接生成 `1x4` 之类长条原始图；优先 `2x2`、`2x3`、`2x4`、`3x3`、`4x4`。
- 每帧主体必须居中、比例稳定、脚底/底部 anchor 稳定，不能贴边。
- 地图 props pack 只适合紧凑小物件；建筑、大树、长围栏、桥、门等应单独生成或使用宽格。

## `generate2dmap` 要点

- 可玩地图不能只是一张 baked image，除非明确标记为纯概念/参考。
- 地图应拆分为 base、props、collision、zones、scene hooks、preview 等。
- base/foundation 层不能烘焙运行时需要独立控制的对象。
- 树、建筑、门、箱子、采集物、可破坏物、怪物、NPC、玩家等必须作为独立对象或对象层。
- layered map 需要 placement metadata、collision metadata、zones metadata。
- dressed-reference / stage-reference 只能作为参考，不是最终运行时地图。

## 当前项目资产目录

```text
art/concepts/                # 概念图
art/style-exploration/       # 风格探索图
art/sprites/                 # 角色、道具、作物等 sprite
art/maps/                    # 地图层、预览、metadata
art/effects/                 # 工具/战斗/法术特效
art/production-runs/         # 生产记录
tools/                       # 资产生产工具记录或 submodule
```

## 推荐接入的 `agent-sprite-forge` 内容

当前已读取 `D:\agent-sprite-forge`，对本项目最有用的内容是：

```text
skills/generate2dsprite/SKILL.md
skills/generate2dsprite/references/modes.md
skills/generate2dsprite/references/prompt-rules.md
skills/generate2dsprite/scripts/generate2dsprite.py
skills/generate2dsprite/scripts/make_layout_guide.py

skills/generate2dmap/SKILL.md
skills/generate2dmap/references/layered-map-contract.md
skills/generate2dmap/references/prop-pack-contract.md
skills/generate2dmap/references/map-strategies.md
skills/generate2dmap/scripts/extract_prop_pack.py
skills/generate2dmap/scripts/compose_layered_preview.py
```

其中：

- `make_layout_guide.py`：生成网格布局参考图，适合 prop pack、tileset-like atlas、固定帧表。
- `generate2dsprite.py process`：对 Image2 生成的 sprite sheet 做 magenta cleanup、切帧、对齐、QC、透明导出和 GIF 导出。
- `extract_prop_pack.py`：从 prop pack sheet 中抽取单个 prop PNG，并生成 manifest。
- `compose_layered_preview.py`：把 base map 和 placement JSON 合成为 QA preview。

这些脚本需要 Python 图像处理依赖。当前本机 `python` 环境缺少 Pillow，后续要么安装 Pillow，要么用 fork 仓库推荐的依赖环境执行。

## 命令模板

### 生成布局参考

```powershell
python D:\agent-sprite-forge\skills\generate2dsprite\scripts\make_layout_guide.py `
  --rows 3 `
  --cols 3 `
  --cell-width 384 `
  --cell-height 384 `
  --output art\production-runs\<run-id>\layout-guide.png
```

### 处理单个 sprite sheet

```powershell
python D:\agent-sprite-forge\skills\generate2dsprite\scripts\generate2dsprite.py process `
  --input art\production-runs\<run-id>\raw.png `
  --target prop `
  --mode single `
  --rows 1 `
  --cols 1 `
  --output-dir art\sprites\<asset-name> `
  --fit-scale 0.9 `
  --align feet `
  --component-mode largest `
  --component-padding 8 `
  --min-component-area 200 `
  --threshold 100 `
  --edge-threshold 150 `
  --edge-clean-depth 2 `
  --reject-edge-touch
```

### 抽取 prop pack

```powershell
python D:\agent-sprite-forge\skills\generate2dmap\scripts\extract_prop_pack.py `
  --input art\production-runs\<run-id>\prop-pack-alpha.png `
  --rows 3 `
  --cols 3 `
  --labels tree,stump,untilled-plot,tilled-plot,seeded-plot,watered-plot,mature-plot,fence,crate `
  --output-dir art\sprites\props `
  --manifest art\sprites\props\prop-pack.json `
  --component-mode largest `
  --component-padding 8 `
  --min-component-area 200 `
  --reject-edge-touch
```

### 合成 layered preview

```powershell
python D:\agent-sprite-forge\skills\generate2dmap\scripts\compose_layered_preview.py `
  --base art\maps\homestead_v1\base.png `
  --placements art\maps\homestead_v1\props.json `
  --output art\maps\homestead_v1\layered-preview.png `
  --report art\maps\homestead_v1\preview-report.json `
  --project-root D:\collapse
```

## 本项目下一批合格资产建议

下一批不应继续生成整张背景图。建议按以下顺序：

1. `generate2dmap`：生成 `homestead_v1_base.png`，只包含地面、道路、净化灯底座、农田底座位置，不包含建筑/树/角色。
2. `generate2dsprite`：单独生成 player cabin、potion shop、tree、farm plot states。
3. 用 `extract_prop_pack.py` 或 `generate2dsprite.py process` 生成透明单体 PNG。
4. 写 `homestead_v1_props.json`、`homestead_v1_collision.json`、`homestead_v1_zones.json`。
5. 用 `compose_layered_preview.py` 输出 `homestead_v1_layered-preview.png`。
6. Godot 加载 base + props JSON + collision JSON，而不是加载整张静态地图。

## 提交前验证

```powershell
godot_console.exe --headless --path . --quit-after 5
```

如果新增图片：

```powershell
godot_console.exe --headless --path . --import
```

生成资产、导入元数据、生产记录和接入代码必须一起提交。
