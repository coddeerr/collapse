# Codex 项目规则

本仓库必须使用 `agent-sprite-forge` 作为游戏美术资产的生产流程。

## 强制资产规则

任何准备进入游戏运行时的美术资产，都必须通过以下两个 skill 之一：

- `D:\agent-sprite-forge\skills\generate2dsprite\SKILL.md`
- `D:\agent-sprite-forge\skills\generate2dmap\SKILL.md`

不要只靠自由手写 prompt 生成运行时用的角色、道具、特效、建筑或可玩地图。

允许生成概念图，但概念图只能放在：

```text
art/concepts/
art/style-exploration/
```

概念图不能作为最终游戏资产直接接入运行时玩法。

## Skill 选择规则

以下内容使用 `generate2dsprite`：

- 玩家角色
- NPC
- 生物 / 怪物
- 工具
- 道具
- 可放置建筑
- 作物
- 树木
- 投射物
- 法术特效
- 命中特效
- 动画帧表

以下内容使用 `generate2dmap`：

- 可玩的村庄地图
- 分层 raster 地图
- 基础地形层
- 地图道具摆放
- 碰撞元数据
- 触发区
- 场景 hook
- 地图预览图

如果一个需求同时包含地图和 sprite，必须同时使用两个 skill，并保持输出分离。

## 必须记录生产过程

每次生成运行时资产，都必须在以下目录创建一份 Markdown 记录：

```text
art/production-runs/
```

记录必须包含：

- 日期和目的
- 使用的 skill
- skill 源文件路径
- 完整 prompt
- 使用 `generate2dmap` 时的 visual model / runtime object model
- 使用 `generate2dsprite` 时的 asset type / action / view / sheet / frames / bundle
- 原始输出路径
- 后处理命令
- 最终输出路径
- QC 结果
- Godot 接入说明

如果缺少这份记录，生成出来的文件不算合格的运行时资产。

## 运行时资产要求

运行时资产必须满足对应 skill 的契约：

- 视觉美术必须来自 Image2 / 图像生成，而不是程序绘制的几何占位图。
- 原始 sprite sheet 默认使用纯 `#FF00FF` chroma-key 背景，除非 skill 明确要求其他流程。
- 最终 sprite 应尽可能是透明 PNG。
- 地图不能是一张烘焙好的完整玩法截图，除非明确标记为概念图或参考图。
- 可玩地图需要拆出独立对象、碰撞、区域、scene hooks 或摆放元数据。
- 可控制主角的动作应先分别生成独立 action sheet，再组装最终 atlas。
- 宽幅攻击特效应是独立 FX sheet，不要烘焙进主角身体动作帧里。

## 当前本地 Skill 来源

当前本地 fork 路径：

```text
D:\agent-sprite-forge
```

在生成任何运行时资产之前，当前会话必须先读取该路径下对应的 `SKILL.md`。

## Godot 接入规则

Godot 运行时代码和资产生产工具必须分离：

```text
tools/agent-sprite-forge/   # 可选 submodule / 工具副本
art/                        # 生成资产和生产记录
scenes/                     # Godot 场景
scripts/                    # Godot 脚本
```

不要让 `agent-sprite-forge` 成为玩家运行游戏时的依赖。

## 验证规则

提交资产接入前，必须运行：

```powershell
godot_console.exe --headless --path . --quit-after 5
```

如果新增了图片文件，还必须运行：

```powershell
godot_console.exe --headless --path . --import
```

生成资产、导入元数据、生产记录和接入代码必须一起提交。
