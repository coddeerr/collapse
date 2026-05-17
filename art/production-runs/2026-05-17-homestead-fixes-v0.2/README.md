# Homestead Fixes V0.2

Date: 2026-05-17

Purpose: Improve first-playable homestead feel after user review:

- smaller, varied trees that sit better on the map
- teenage protagonist combat/cast body actions
- runtime interaction fixes handled in `scripts/main.gd`

Skill rules read:

- `D:\agent-sprite-forge\skills\generate2dsprite\SKILL.md`
- `D:\agent-sprite-forge\skills\generate2dmap\references\prop-pack-contract.md`

Important decisions:

- Trees are tall/large objects, so each tree variant is generated one-by-one.
- Hero attack, physical skill, and spell cast body sheets are separate action
  sheets. Wide slash/projectile/impact effects remain separate runtime layers.

