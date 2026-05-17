# Asset Production Plan v0.1

This file defines the first production targets for the `agent-sprite-forge` workflow.

## Integration Decision

`agent-sprite-forge` should be treated as an art production tool, not as Godot runtime code.

Preferred layout:

```text
tools/agent-sprite-forge/   # Git submodule when GitHub access is stable
art/sprites/                # Generated character and prop sprites
art/maps/                   # Generated map layers and previews
art/effects/                # Generated combat and tool effects
```

Current note: adding the submodule from GitHub failed because the local connection to GitHub was reset. The project keeps the production contract here so work can continue.

## Style Lock

- Camera: light 45-degree overhead.
- Style: hand-painted 2D, warm post-apocalyptic fairy-tale survival.
- Theme: Lantern Frontier, a warm human safe zone surrounded by mutated ecology.
- Readability: clear silhouettes, clean action frames, usable in Godot 2D.
- Avoid: photorealism, horror gore, heavy occlusion, UI text, watermarks.

## Sprite Targets

### Player Character

Output folder:

```text
art/sprites/player/
```

Required sheets:

- `player_idle_8dir.png`
- `player_walk_8dir.png`
- `player_slash_8dir.png`
- `player_physical_skill_8dir.png`
- `player_spell_skill_8dir.png`

Suggested frame spec:

- Idle: 4 frames per direction.
- Walk: 6 frames per direction.
- Slash: 5 frames per direction.
- Physical skill: 6 frames per direction.
- Spell skill: 6 frames per direction.
- Cell size: 64x80 or 96x96.
- Anchor: bottom center.

Prompt seed:

```text
Generate a player character spritesheet for a light 45-degree overhead 2D Godot game.
Style: hand-painted warm post-apocalyptic fairy-tale survival, Lantern Frontier.
Character: young survivor village guardian, practical repaired clothing, small backpack, warm scarf, simple boots, readable silhouette.
Action: <idle/walk/slash/physical_skill/spell_skill>, 8 directions, consistent character identity.
No background, no UI, no text, no watermark.
```

## Map Targets

Output folder:

```text
art/maps/homestead_v0/
```

Required layers:

- `homestead_base.png`
- `homestead_buildings.png`
- `homestead_props.png`
- `homestead_collision.json`
- `homestead_zones.json`
- `homestead_preview.png`

Map contents:

- Player house.
- Potion shop.
- 6 farm plots.
- Dirt paths.
- Trees that can be chopped.
- Safe-zone fence.
- Purification lamps.
- Mutated ecology at the border.

Prompt seed:

```text
Generate a layered map concept for a light 45-degree overhead 2D Godot homestead.
Style: Lantern Frontier, warm safe-zone village inside a mutated post-disaster world.
Layers: base ground, buildings, props, collision shapes, interaction zones, preview.
Must include player house, potion shop, 6 farm plots, dirt paths, trees, fence, purification lamps, mutated border.
Readable gameplay layout, no UI, no text, no watermark.
```

## Effect Targets

Output folder:

```text
art/effects/
```

Required sheets:

- `tool_hoe_swing.png`
- `tool_axe_chop.png`
- `weapon_slash_basic.png`
- `skill_physical_impact.png`
- `skill_spell_spark.png`

Effect style:

- Warm amber safe-light for spell effects.
- Pale blue-white force for physical impact.
- Clean arcs for slash and tool swings.
- Transparent PNG target after background removal.
