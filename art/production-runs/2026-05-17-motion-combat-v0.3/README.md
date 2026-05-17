# Motion Combat V0.3

Date: 2026-05-17

Purpose:

- Regenerate the teenage hero walk cycle with stronger readable limb motion.
- Replace physical shockwave with forward lunge slash.
- Add a separate fireball projectile asset for the spell.

Skill rules read:

- `D:\agent-sprite-forge\skills\generate2dsprite\SKILL.md`
- `D:\agent-sprite-forge\skills\generate2dsprite\references\prompt-rules.md`

Notes:

- Building rotation is not solved with naive bitmap rotation. 45-degree
  building rotation needs authored directional building views in a later pass.
- The current runtime rotates footprints/placement rules and keeps the best
  facing cabin art.

