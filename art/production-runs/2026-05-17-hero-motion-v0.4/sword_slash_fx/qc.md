# QC

Status: blocked before raw generation

Reason:

- The local Cherry Studio Image2 endpoint is reachable, but it currently rejects requests without credentials.
- `tools\generate_cherry_image2.py` requires `CHERRY_API_KEY`.
- The current shell session has no `CHERRY_API_KEY` value.

Commands attempted:

- `C:\Users\Admin\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe tools\generate_cherry_image2.py --prompt art\production-runs\2026-05-17-hero-motion-v0.4\sword_slash_fx\prompt.txt --out art\production-runs\2026-05-17-hero-motion-v0.4\sword_slash_fx\raw.png --response art\production-runs\2026-05-17-hero-motion-v0.4\sword_slash_fx\raw.response.json`

Runtime fallback:

- This pass uses a deterministic in-engine sword and sword-trail overlay so direction, hand attachment, and body style stay consistent.
