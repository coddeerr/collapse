# agent-sprite-forge 接入记录

日期：2026-05-17

## 当前状态

计划使用 `agent-sprite-forge` 的资产生产思路，为本项目生成 2D 角色、建筑、农田、树木、技能特效和地图层。

本轮尝试访问：

- `https://github.com/coddeerr/agent-sprite-forge.git`
- `https://github.com/0x0funky/agent-sprite-forge.git`

结果：本机 GitHub 连接超时或被重置，因此暂不把该仓库作为 submodule 固定进项目。当前先在项目内记录工作流，后续网络稳定后再放入：

```text
tools/agent-sprite-forge/
```

## 采用的工作方式

先把 sprite-forge 当作生产规范，而不是运行时依赖。

核心 skill：

- `generate2dsprite`：生成主角、工具、怪物、技能特效、动作帧。
- `generate2dmap`：生成村庄地图、分层场景、碰撞层、触发区、预览图。

## 本项目首批资产需求

### 主角

- 轻 45 度俯视。
- 手绘 2D。
- 温暖废土童话。
- 8 方向移动。
- 动作：idle、walk、slash、physical_skill、spell_skill。
- 角色尺寸建议：48x64 或 64x80。

### 家园地图

- 轻 45 度俯视村庄。
- 分层：base、buildings、props、collision、zones、preview。
- 包含：主角小屋、药剂店、农田、树木、围栏、净化灯、污染边界。

### 工具和技能

- 工具：锄头、种子、水壶、斧头、短剑。
- 技能：基础挥砍、物理冲击、星火法术。

## 当前原型实现

在 `scripts/main.gd` 中先使用代码绘制占位图实现：

- 8 方向移动。
- 基础碰撞。
- 开垦、播种、浇水、收获。
- 工具栏滚轮切换。
- 斧头砍树、短剑挥砍、物理技能、法术技能。
- 昼夜轮替。

后续目标是用本文件的规范生成正式 PNG/Spritesheet，再替换代码绘制占位图。
