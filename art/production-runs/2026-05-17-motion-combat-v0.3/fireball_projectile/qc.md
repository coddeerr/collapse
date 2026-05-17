# QC

Status: accepted

Forge path:

- Skill: `D:\agent-sprite-forge\skills\generate2dsprite`
- Processor: `generate2dsprite.py process`
- Input: `raw.png`
- Output: `processed_256\sheet-transparent.png`

Runtime copy:

- `D:\collapse\art\effects\fireball\fireball.png`

Checks:

- 2 by 2 projectile animation sheet.
- Bright core and flame trail remain readable at small runtime size.
- Transparent-background output is available for Godot rendering.
- No edge-touch rejection occurred during forge processing.
