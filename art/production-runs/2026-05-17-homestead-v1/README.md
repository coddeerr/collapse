# Homestead V1 Production Run

Date: 2026-05-17

Purpose: Create the first auditable runtime asset batch for the light 45-degree
homestead prototype. Every visible runtime asset in this folder must keep its
prompt, raw Image2 output, postprocess command, final output, and QC notes.

Required skills read before generation:

- `D:\agent-sprite-forge\skills\generate2dsprite\SKILL.md`
- `D:\agent-sprite-forge\skills\generate2dmap\SKILL.md`
- `C:\Users\Admin\.codex\skills\.system\imagegen\SKILL.md`

Pipeline:

- Creative raw art source: Image2 through local Cherry Studio endpoint.
- Sprite/object cleanup: `agent-sprite-forge` scripts.
- Map model: `scene_mode`, `layered_raster`, `y_sorted_props`,
  `precise_shapes`, `project-native`.
- Base map rule: ground and paths only; buildings, trees, crops, player, and
  interactables are separate runtime assets.

