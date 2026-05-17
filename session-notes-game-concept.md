# 游戏概念与资产流程记录

日期：2026-05-17

## 1. Cherry Studio 本地生图能力

- Cherry Studio 已在本机运行，并启用了本地 API Server。
- 本地地址：`http://127.0.0.1:23333`
- OpenAPI 文档：`http://127.0.0.1:23333/api-docs.json`
- 当前没有独立的 `/v1/images` 生图接口。
- 可通过 `/v1/chat/completions` 调用已配置的生图模型。
- 当前可用模型：`d84daab0-0459-4f3b-99f8-ff8408e1d091:gptimage2`
- 生图返回格式是 Markdown 内嵌 `data:image/png;base64,...`。
- 已成功生成测试图：`C:\Users\Admin\Documents\Codex\2026-05-17\new-chat\cherry-red-apple-test.png`

## 2. 2D 游戏资产生成链路

2D 游戏资产生成链路可以理解为：从“游戏需要什么”到“能直接进引擎使用的素材包”的流程。

核心步骤：

- 需求定义：确定资产类型、用途、尺寸、风格、数量、动画需求。
- 风格设定：定义整体美术方向，例如像素风、手绘、水彩、赛璐璐、Q版。
- 资产分类：角色、场景、道具、UI、特效、图标、Tile、背景等。
- 生成草图：用文字提示词、参考图或草图生成初版视觉。
- 筛选与迭代：挑选方向正确的结果，修正造型、颜色、比例、细节。
- 拆分与清理：去背景、切图、分层、补透明通道、统一边缘。
- 规格化处理：统一尺寸、分辨率、锚点、命名、导出格式。
- 动画制作：制作帧动画、骨骼动画、表情、攻击、待机、移动等。
- 打包进引擎：生成 spritesheet、atlas、tilemap、UI sprite，并导入 Unity/Godot。
- 测试与回修：检查可读性、碰撞、比例、动画节奏、性能。

关键定义：

- Asset：游戏中可复用的美术资源。
- Sprite：单张 2D 图像，通常带透明背景。
- Spritesheet：把多张 Sprite 排在一张大图里，常用于动画。
- Atlas：把多个独立资产打包成一张纹理图，减少 draw call。
- Tile：用于拼地图的小块。
- Tilemap：由 Tile 拼出来的地图。
- Frame Animation：逐帧动画。
- Pivot/Anchor：精灵中心点或挂点，影响对齐和碰撞。
- Collision Shape：碰撞区域。
- Palette：调色板。
- Silhouette：外轮廓，影响可读性。
- Readable Size：素材在实际游戏镜头里的清晰度。

AI 生图特别重要的定义：

- Style Lock：锁定风格，保证资产一致。
- Character Sheet：角色三视图、表情、动作姿势集合。
- Prompt Template：固定提示词模板，用于批量生成一致素材。
- Reference Image：参考图，用来控制角色、风格或构图。
- Seed：随机种子，用于复现相似结果。
- Post-processing：后处理，包括抠图、修边、缩放、锐化、像素化、调色。
- Production Spec：生产规格，例如 PNG 透明背景、512x512、32px tile、4 方向移动。

核心原则：风格一致、规格统一、能进游戏用。

## 3. agent-sprite-forge 相关理解

讨论过 GitHub 仓库 `coddeerr/agent-sprite-forge`，公开可检索到的同名主要仓库是 `0x0funky/agent-sprite-forge`。

它不是游戏引擎，也不是普通提示词库，而是一套给 Codex 用的 2D 游戏资产生产流程。

它主要包括两个 Skill：

- `generate2dsprite`：生成角色、怪物、NPC、道具、法术、投射物、命中特效、动画帧。
- `generate2dmap`：生成地图、分层场景、道具包、碰撞、触发区、Godot/Unity 可用数据。

Skill 的含义：

- Skill 是给 Codex 的“专项工作说明书 + 工具包”。
- 它规定遇到某类任务时，Codex 应该如何判断资产类型、写提示词、调用脚本、产出文件。
- 它不是游戏里的技能，也不是模型本身。

Skill 和普通提示词的区别：

- 普通提示词只负责“画一张图”。
- Skill 负责把需求变成可生产、可切图、可导入游戏的资产流程。

`generate2dsprite` 关注：

- asset_type：资产类型，如 player、npc、creature、spell、projectile。
- action：动作，如 idle、walk、attack、cast、death。
- view：视角，如 topdown、side、3/4。
- sheet：帧表布局，如 2x2、2x3、4x4。
- frames：动画帧数。
- bundle：资产包类型，如角色动作包、法术包、战斗包。
- anchor：锚点，如中心、脚底、底部。

`generate2dmap` 关注：

- tile_mode：瓦片地图，适合 RPG、宝可梦式地图。
- scene_mode：基础地图 + 独立道具。
- side_scroll_mode：横版卷轴地图。
- grid_mode：战棋、棋盘、工厂类网格地图。
- baked_scene_mode：纯背景图，不强调可编辑或可碰撞。

地图部分的重要原则：

- 可玩的地图不能只是一张漂亮背景图。
- 应拆成 base、props、collision、zones、preview 等层。
- base 是地面、道路、水面。
- props 是树、箱子、灯、石头等独立物体。
- collision 是碰撞区域。
- zones 是触发区域。
- preview 是合成预览图。

## 4. 参考游戏：星露谷物语

`Stardew Valley` 是乡村生活 RPG / 农场经营游戏。

核心玩法：

- 玩家继承爷爷的旧农场。
- 清理土地、种植作物、养动物、钓鱼、采矿、战斗、制作物品。
- 和小镇居民建立关系、约会、结婚、过节。
- 按天、季节、年份推进，玩家自己决定目标。

值得学习的地方：

- 短循环：每天起床、浇水、收菜、卖货、下矿、回家睡觉。
- 中循环：一季种什么、升级什么工具、攒钱买什么建筑。
- 长循环：修复社区中心、经营完整农场、和 NPC 建立关系。
- 情绪价值：让玩家感到“我在慢慢建设自己的生活”。

关键启发：

- 给玩家很多小目标。
- 让玩家每天都想“再玩一天”。
- 核心不是种田本身，而是生活感、自由度和持续成长。

## 5. 参考游戏：猎魔村物语

`猎魔村物语` 通常对应英文名 `Evil Hunter Tycoon`。

核心设定：

- 魔王毁灭世界后，玩家成为村长。
- 玩家重建村庄，为猎人提供设施和装备。
- 猎人会自动打怪、刷资源、成长。
- 玩家负责建造、制作、出售、训练、强化猎人。

核心循环：

- 猎人打怪获得材料。
- 材料回到村庄。
- 玩家用材料制作装备、药品、设施。
- 猎人变强，挑战更强怪物。
- 解锁更高级区域、建筑、职业、系统。

值得学习的地方：

- 村庄不是装饰，而是功能系统。
- 猎人不是单纯 NPC，而是资源生产者和战斗单位。
- 建筑服务猎人，猎人反过来推动村庄成长。
- 玩家乐趣来自“看系统自己运转，然后优化它”。

## 6. 最终游戏方向

目标方向：做一款结合《星露谷物语》和《猎魔村物语》亮点的游戏。

一句话概念：

经营一个给冒险者服务的温暖小村庄。

核心融合：

- 星露谷式生活经营：季节、天气、节日、NPC 好感、农田、钓鱼、采集、村庄故事。
- 猎魔村式成长闭环：冒险者打怪、带回材料、制作装备、升级建筑、挑战更强区域。
- 玩家白天种田、经营商店、修复村庄、和居民交流。
- 冒险者自动出门打怪，回村消费药水、装备、旅馆、训练等服务。
- 玩家通过村庄生产链支持冒险者成长。

有潜力的创新点：

- 冒险者也有好感和日常。
- 农场服务战斗，例如种药草做药水，种小麦供旅馆。
- 村庄经济闭环：村民生产，冒险者消费，玩家调配供应链。
- 季节影响战斗，例如冬天冰系怪多，夏天火山区域开放。
- 事件驱动防守，例如满月怪潮、丰收祭、冒险者比赛、商队来访。
- 玩家可亲自下副本，也可派冒险者自动探索。

## 7. 第一版最小闭环

不要一开始做完整游戏，而是先做 15 分钟内能体验到成长反馈的最小闭环原型。

第一版目标：

- 玩家种植药草。
- 药草成熟后收获。
- 在药剂店制作小药水。
- 冒险者自动购买药水。
- 冒险者出村打怪。
- 冒险者回来带回怪物材料。
- 玩家用材料升级药剂店。

推荐技术路线：

- 引擎：Godot 4
- 视角：俯视角 2D
- 画面：先用占位图块，不急着精美
- 美术：后续再用 Cherry Studio / sprite forge 流程生成

第一阶段系统：

- 时间系统：一天 3 分钟，白天种田，夜晚结算。
- 农田系统：点击空地播种，等待成熟，点击收获。
- 背包系统：记录药草、药水、怪物材料。
- 制作系统：2 药草 = 1 小药水。
- 冒险者 AI：自动走到药剂店，买药水，然后出村。
- 战斗结算：不做实时战斗，先用概率结算。
- 升级系统：5 怪物材料 + 10 金币 = 药剂店 Lv2。

最小数据定义：

- Crop：作物，包含名称、成长时间、产物数量。
- Item：物品，例如药草、药水、怪物材料。
- Building：建筑，例如药剂店，包含等级、库存、功能。
- Adventurer：冒险者，包含血量、金币、状态。
- Recipe：配方，例如药草变药水。
- Expedition：出征结果，例如消耗药水、获得材料。

第一版不要做：

- 不做完整 NPC 好感。
- 不做复杂装备系统。
- 不做多个职业。
- 不做大地图探索。
- 不做四季、节日、结婚。
- 不做实时战斗。
- 不追求精美美术。

第一周任务建议：

- 第 1 天：确定一页纸玩法文档。
- 第 2 天：搭 Godot 项目，做村庄场景。
- 第 3 天：做农田种植和收获。
- 第 4 天：做背包和制作药水。
- 第 5 天：做冒险者自动购买药水。
- 第 6 天：做出征结算和材料回收。
- 第 7 天：做药剂店升级和简单 UI。

最小可玩标准：

玩家通过种药草制作药水，冒险者买药水后出村打怪，带回材料，玩家再升级药剂店。

## 8. 当前项目仓库状态

本节记录于 2026-05-17 后续开发阶段。

### 8.1 远端仓库

- GitHub 仓库：`https://github.com/coddeerr/collapse`
- Git 远端地址：`https://github.com/coddeerr/collapse.git`
- 主分支：`main`
- 首次提交：`48d87e5 Initial Godot prototype`

### 8.2 本地仓库

- 当前正式工作目录：`D:\collapse`
- Godot 项目入口：`D:\collapse\project.godot`
- 旧的临时工作目录：`C:\Users\Admin\Documents\Codex\2026-05-17\new-chat`
- 后续继续开发时，应优先使用 `D:\collapse`，不要再使用 `new-chat` 目录。

### 8.3 当前已实现的 Godot 原型

已创建 Godot 4 项目，核心文件包括：

- `D:\collapse\project.godot`
- `D:\collapse\scenes\main.tscn`
- `D:\collapse\scripts\main.gd`
- `D:\collapse\README.md`
- `D:\collapse\game-design-v0.1.md`

当前原型已实现：

- 4 块农田。
- 点击农田播种药草。
- 药草成熟后点击收获。
- 使用 2 个药草制作 1 个小药水。
- 药剂店储存小药水。
- 冒险者自动购买小药水。
- 冒险者自动出村讨伐。
- 冒险者返回后带回怪物材料。
- 使用怪物材料和金币升级药剂店。

### 8.4 当前体验方式

用户本机已安装 Godot。

体验方式：

1. 打开 Godot。
2. Import 项目。
3. 选择 `D:\collapse\project.godot`。
4. 打开项目后点击运行。

也可以在 PowerShell 中运行：

```powershell
cd D:\collapse
godot.exe --path .
```

### 8.5 当前注意事项

- 之后开发请以 `D:\collapse` 为准。
- 目前还没有继续修改 `D:\collapse` 中的代码，只是从远端 clone 并验证项目可加载。
- 用户刚刚要求“先不要执行命令，先保存 context”，所以后续新 session 应先读取本文件和 `game-design-v0.1.md`，再继续。
- 如需启动 Godot 可见窗口，需要用户确认或由用户自己手动打开。

### 8.6 建议下一步

下一步可以从以下方向继续：

- 让用户先试玩当前原型，收集体验反馈。
- 如果不能运行，优先修 Godot 报错。
- 如果能运行，下一步建议改善交互反馈，例如成熟提示、按钮布局、冒险者路径、数值节奏。
- 再下一步可以拆分 `scripts/main.gd`，把农田、库存、冒险者、药剂店拆成独立脚本。

## 9. 2026-05-17 后续开发进展

### 9.1 游戏入口

已新增 Windows 启动入口：

- `D:\collapse\play_game.bat`

双击该文件会自动从 `D:\collapse` 启动 Godot 项目并运行主场景：

- `res://scenes/main.tscn`

该入口不会锁定旧版本；只要后续开发继续更新 `D:\collapse`，双击同一个 bat 就会体验当前最新项目状态。

### 9.2 原型交互反馈增强

已更新 `D:\collapse\scripts\main.gd`：

- 新增“下一步”目标提示。
- 新增农田状态统计：空地、成长中、可收获。
- 药草成长中显示绿色进度条。
- 成熟农田显示发亮边框和亮点提示。
- 冒险者出征时显示进度条。

验证命令：

```powershell
godot_console.exe --headless --path . --quit
```

### 9.3 视角结论

当前选择：

- 使用轻 45 度俯视表现。
- 底层逻辑仍保持 2D 俯视/网格友好。

原因：

- 比纯俯视更有作品感和村庄空间感。
- 比严格等距视角更易控制点击、寻路、建筑遮挡和防守路线。
- 适合先做经营/防守玩法，再逐步替换正式美术。

### 9.4 世界观与美术风格结论

用户确认的世界观基底：

- 一系列灾难导致地球生物变异。
- 人类适合生存的家园不断缩小。
- 玩家守护一片仍适合人类生存的小区域。
- 怪物觊觎这片土地，会在夜晚攻打村庄。
- 玩家有时必须进入非安全区收集材料、战斗和探索。

当前推荐并采用的美术方向暂名：

- 灯火边境 / Lantern Frontier

核心风格：

- 轻 45 度俯视。
- 手绘 2D。
- 温暖废土童话。
- 生态异变。
- 小型幸存者村庄。
- 安全光源。
- 污染边界。
- 夜晚怪物潮。

核心情绪：

- 村庄是值得守护的。
- 村外世界不是普通黑暗，而是生态上“不对劲”。
- 白天偏经营和修复，夜晚偏防守和压力。

### 9.5 Image2 / Cherry Studio 美术生成闭环

已通过本地 Cherry Studio API 调用 `gptimage2` 生成概念图。

链路：

- 本地 API：`http://127.0.0.1:23333/v1/chat/completions`
- 模型：`d84daab0-0459-4f3b-99f8-ff8408e1d091:gptimage2`
- 返回格式：Markdown 内嵌 `data:image/png;base64,...`
- 保存位置：`D:\collapse\art\...`

已保存概念图：

- `D:\collapse\art\concepts\village-topdown-concept.png`
- `D:\collapse\art\concepts\village-three-quarter-concept.png`
- `D:\collapse\art\style-exploration\style-01-safe-zone-day.png`
- `D:\collapse\art\style-exploration\style-02-polluted-boundary-dusk.png`
- `D:\collapse\art\style-exploration\style-03-night-attack.png`
- `D:\collapse\art\style-exploration\art-direction-v0.1.md`

## 10. 家园原型开发计划与当前实现

用户希望基于“灯火边境”美术框架，先做初始家园和主角，暂不做怪物攻城。

### 10.1 当前实现范围

已在 `D:\collapse\scripts\main.gd` 中改为家园原型：

- 主角可操作移动，支持 8 个移动方向。
- 基本村庄占位场景：轻 45 度表现、家屋、药剂店、道路、树木、污染边界、安全灯。
- 基础碰撞：建筑、树木、场景边界。
- 农田组件：开垦、播种、浇水、成熟、收获。
- 工具栏：锄头、种子、水壶、斧头、短剑、物理技能、法术技能。
- 鼠标滚轮或数字键 `1-7` 切换工具。
- 鼠标左键或空格使用工具。
- 主角动作占位：挥砍、物理冲击、星火法术。
- 昼夜轮替效果。

### 10.2 暂不做内容

- 暂不做怪物攻城。
- 暂不做怪物 AI。
- 暂不做正式 spritesheet。
- 暂不做复杂背包和装备属性。

### 10.3 agent-sprite-forge 接入状态

已尝试访问 GitHub 仓库：

- `https://github.com/coddeerr/agent-sprite-forge.git`
- `https://github.com/0x0funky/agent-sprite-forge.git`

本机网络对 GitHub 连接超时或重置，因此暂未作为 submodule 引入。

当前先在项目内新增：

- `D:\collapse\tools\agent-sprite-forge-notes.md`

用于记录后续用 `generate2dsprite` / `generate2dmap` 生成正式主角、地图、工具、技能特效的规范。
