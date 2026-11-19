# bend-crypto

Cryptographic primitives in [Bend](https://github.com/bendlang/bend), each
checked against its specification by machine-verified proof.

Every primitive comes with laws in `LAWS.bend`: the specification's test
vectors and the properties the algorithm depends on. `PROOF.bend` proves
them, and the proofs are rechecked by Bend's Lean-verified kernel.

```sh
make gate
```

Bend makes no constant-time guarantee. These implementations are correct,
not hardened against side channels.

## License

[MIT](LICENSE)
