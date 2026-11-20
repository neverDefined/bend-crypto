# Decisions

- 2026-11-19: The repo builds cryptographic primitives in Bend and nothing else.
- 2026-11-19: Correctness is proof, not tests: every primitive ships with laws for its specification's
  test vectors and its algebraic properties, checked by `bend PROOF.bend --verdict`.
- 2026-11-19: Bend 2.0.40, pinned in CI and checked by sha256.
- 2026-11-19: One folder per primitive, laid out like Bend's demos (`main`, `SPEC`, `LAWS`, `PROOF`).
  Laws replace unit tests.
- 2026-11-19: SHA-256 hashes whole-byte messages only; FIPS 180-4 bit-length messages are out of scope.
- 2026-11-19: No million-"a" SHA-256 vector: Bend 2.0.40's checker overflows building a 100,000-byte
  list, so it cannot be a law.
