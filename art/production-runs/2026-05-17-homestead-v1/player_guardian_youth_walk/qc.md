# QC - player_guardian_youth_walk

Status: accepted after retry

Reason:

- The youth identity is acceptable.
- Forge postprocess rejected the sheet because several frames touched cell
  edges: `[0,3]`, `[3,0]`, `[3,1]`, `[3,2]`, `[3,3]`.
- This raw sheet is retained as an intermediate artifact and must not be used
  as the runtime walk animation.

Accepted retry:

- `raw.retry1.png`
- Prompt: `prompt.retry1.txt`
- Forge output: `processed_retry1_256/sheet-transparent.png`
- `edge_touch_frames`: `[]`

Runtime copy:

- `art/sprites/player/guardian_youth/walk.png`
