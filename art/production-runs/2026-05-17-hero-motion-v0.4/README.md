# Hero Motion V0.4

Date: 2026-05-17

Purpose:

- Keep idle and walk visual style consistent by using the accepted walk sheet as the directional idle source.
- Keep the stopped-facing direction instead of always showing one idle angle.
- Improve sword attack readability with a separate sword/slash FX layer.
- Fix slide slash direction so it always follows the character facing vector.

Skill rules read:

- `D:\agent-sprite-forge\skills\generate2dsprite\SKILL.md`
- `D:\agent-sprite-forge\skills\generate2dsprite\references\prompt-rules.md`

Research notes:

- Official image generation guidance supports transparent PNG style outputs for assets, but recurring characters and structured sheets can still vary between generations.
- For this prototype pass, the most reliable consistency fix is to reuse the accepted directional walk sheet for idle frames and layer compact sword FX separately.
