# Decisions

- 2026-11-19: The repo builds cryptographic primitives in Bend and nothing else.
- 2026-11-19: Correctness is proof, not tests: every primitive ships with laws for its specification's
  test vectors and its algebraic properties, checked by `bend PROOF.bend --verdict`.
- 2026-11-19: Bend 2.0.40, pinned in CI and checked by sha256.
