# Codex Project Rules

This repository uses `agent-sprite-forge` as the required production workflow for game art assets.

## Mandatory Asset Rule

Any asset intended to be used as runtime game art must go through one of these skills:

- `D:\agent-sprite-forge\skills\generate2dsprite\SKILL.md`
- `D:\agent-sprite-forge\skills\generate2dmap\SKILL.md`

Do not generate runtime sprites, props, effects, buildings, or playable maps by freehand prompt alone.

Concept images are allowed, but they must stay under:

```text
art/concepts/
art/style-exploration/
```

Concept images must not be wired into runtime gameplay as final assets.

## Skill Selection

Use `generate2dsprite` for:

- player characters
- NPCs
- creatures
- tools
- props
- buildings as placeable props
- crops
- trees
- projectiles
- spell effects
- hit impacts
- animation sheets

Use `generate2dmap` for:

- playable village maps
- layered raster maps
- base terrain layers
- map prop placement
- collision metadata
- trigger zones
- scene hooks
- map previews

If a request includes both a map and sprites, use both skills and keep their outputs separate.

## Required Production Run Record

Every runtime asset generation must create a markdown record under:

```text
art/production-runs/
```

The record must include:

- date and purpose
- skill used
- skill source path
- exact prompt
- visual model / runtime object model when using `generate2dmap`
- asset type / action / view / sheet / frames / bundle when using `generate2dsprite`
- raw output paths
- postprocessing commands
- final output paths
- QC result
- Godot integration notes

If this record is missing, the generated file is not considered a valid runtime asset.

## Runtime Asset Requirements

Runtime assets must satisfy the relevant skill contract:

- generated visual art must originate from Image2 / image generation, not procedural code drawing
- raw sprite sheets should use solid `#FF00FF` chroma-key background unless the skill says otherwise
- final sprites should be transparent PNG whenever possible
- maps must not be a single baked gameplay image unless explicitly marked concept/reference only
- playable maps need separate objects, collision, zones, scene hooks, or placement metadata
- controllable hero actions should be generated as separate action sheets before assembling final atlases
- wide attack effects should be separate FX sheets, not baked into the player body sheet

## Current Local Skill Source

The local fork currently exists at:

```text
D:\agent-sprite-forge
```

Before producing runtime assets, read the relevant `SKILL.md` from that location in the current session.

## Godot Integration Rule

Keep Godot runtime code separate from the asset production tool:

```text
tools/agent-sprite-forge/   # optional submodule/tool copy
art/                        # generated assets and production records
scenes/                     # Godot scenes
scripts/                    # Godot scripts
```

Do not make `agent-sprite-forge` a runtime dependency for playing the game.

## Validation

Before committing an asset integration:

```powershell
godot_console.exe --headless --path . --quit-after 5
```

If new image files were added, run:

```powershell
godot_console.exe --headless --path . --import
```

Commit the generated assets, import metadata, production run record, and integration code together.
