# Production Run: Forge Object Assets v0.1

Date: 2026-05-17

## Status

This run is marked **invalid for final runtime art**.

Reason: it was produced after reading the `agent-sprite-forge` skills, but not through a fully compliant `generate2dsprite` / `generate2dmap` execution with postprocessing, transparent extraction, manifest generation, and QC.

The assets may remain as temporary prototype references only.

## Skill Intended

- Intended skill: `generate2dsprite`
- Skill source: `D:\agent-sprite-forge\skills\generate2dsprite\SKILL.md`

## Raw Outputs

- `art/forge_source/buildings_sheet_chroma.png`
- `art/forge_source/props_farm_sheet_chroma.png`

## Integration

The prototype currently uses these sheets as atlas textures in `scripts/main.gd`.

## Missing Requirements

- No successful chroma-key cleanup.
- No extracted transparent prop PNG files.
- No frame/prop manifest.
- No edge-touch QC.
- No component filtering metadata.
- No deterministic slicing output.

## Decision

These files should not be treated as final game assets. The next asset pass must strictly follow `AGENTS.md` and create a new production run record before integration.
