# QC - tree_variant_a

Status: blocked

Reason:

- Local Image2 call timed out/stalled and produced no raw image.
- Runtime tree variety is currently handled through placement scale and flip
  variation using the existing accepted tree asset.

Next action:

- Retry one-by-one tree generation in a later pass. Do not use square prop
  packs for trees because the prop-pack contract classifies trees as
  tall/large objects.

