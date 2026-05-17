# QC

Status: accepted

Forge path:

- Skill: `D:\agent-sprite-forge\skills\generate2dsprite`
- Processor: `generate2dsprite.py process`
- Input: `raw.png`
- Output: `processed_256\sheet-transparent.png`

Runtime copy:

- `D:\collapse\art\sprites\player\guardian_youth\walk.png`

Checks:

- 4 by 4 sheet for down, right, up, and left movement rows.
- Teenage proportions are preserved.
- Arm and leg swing are more readable than the previous walk sheet.
- Feet are aligned for runtime ground contact.
- No edge-touch rejection occurred during forge processing.
