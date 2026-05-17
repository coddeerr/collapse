# Forge Assets v0.1

This batch follows the `agent-sprite-forge` approach more closely than the previous full-scene concept image.

## Goal

Move from one static background image to independent, placeable, interactive game assets.

## Generated With

- Local Cherry Studio API
- Model: `d84daab0-0459-4f3b-99f8-ff8408e1d091:gptimage2`
- Prompt style: Lantern Frontier, light 45-degree overhead, hand-painted 2D game assets

## Source Sheets

- `art/forge_source/buildings_sheet_chroma.png`
- `art/forge_source/props_farm_sheet_chroma.png`

## In-Game Integration

`scripts/main.gd` now treats these sheets as atlas textures:

- Buildings are drawn as independent map objects.
- Trees are drawn as independent chop-able objects.
- Farm plots use separate visual states from the prop sheet.
- Player uses a cropped pose from `art/sprites/player/player_guardian_sheet.png`.

## Known Limitation

The current sheets still use a chroma-key source background because local transparent-background post-processing requires Pillow/ImageMagick, which is not available in the current Python environment. The game can still use atlas regions now; proper alpha cleanup/slicing should be the next asset pipeline improvement.
