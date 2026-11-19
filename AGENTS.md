# bend-crypto

Cryptographic primitives in Bend 2, each proven against its specification. Nothing else: no
protocols, no IO, no CLI. Public repository.

## Build and check

```sh
bend guide         # the language; read it before writing Bend
make gate          # bend PROOF.bend --verdict: must pass before anything merges
```

`src/<primitive>.bend` holds one primitive of pure defs. `LAWS.bend` imports `src/` and states the
claims; `PROOF.bend` proves each one as `def Laws.<name>`. CI pins the Bend version in
`.github/workflows/gate.yml`, and the Lean version `--verdict` needs to build its kernel.

## Rules no check enforces

1. Every primitive cites its specification (FIPS, RFC or SEC section) on the line above its main def.
2. Every primitive has laws: the specification's published test vectors, and the properties the
   algorithm relies on (a round trip, an inverse, a group law). A vector is a law proven by `{==}`.
3. `LAWS.bend` changes only with the owner's approval. Never weaken, delete or reword a law to make a
   proof go through.
4. Bend gives no constant-time guarantee. Never claim side-channel resistance.
5. Names follow Base: `Type.verb`, snake_case, the specification's own terms. A comment says why, never
   what.
6. Read `decisions.md` before changing direction. No plans, status docs or ADRs in the repo.
7. Public text (code, README, commits) carries no personal information. Commits are one line, at most
   72 characters, present tense, scoped (`sha256: add compression function`), with no trailers.
8. Implementers and reviewers never push. Only the owner pushes to `main`.
