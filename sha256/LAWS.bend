# SHA-256: the laws. The owner states them; PROOF.bend proves them.

import Base
import ./main.bend as Sha256
import ./SPEC.bend as Spec

# Each message hashes to its published digest.

law vector_empty:
  {Sha256.encode(Sha256.hash(Spec.empty)) == Spec.empty_md : Spec.Bytes}

law vector_abc:
  {Sha256.encode(Sha256.hash(Spec.abc)) == Spec.abc_md : Spec.Bytes}

law vector_two_block:
  {Sha256.encode(Sha256.hash(Spec.two_block)) == Spec.two_block_md : Spec.Bytes}

law vector_440:
  {Sha256.encode(Sha256.hash(Spec.short_440)) == Spec.short_440_md : Spec.Bytes}

law vector_448:
  {Sha256.encode(Sha256.hash(Spec.short_448)) == Spec.short_448_md : Spec.Bytes}

law vector_504:
  {Sha256.encode(Sha256.hash(Spec.short_504)) == Spec.short_504_md : Spec.Bytes}

law vector_512:
  {Sha256.encode(Sha256.hash(Spec.short_512)) == Spec.short_512_md : Spec.Bytes}

# Padding, for every message.

law pad_aligned:
  for m: Spec.Bytes
  {Nat.mod(Spec.len(Sha256.pad(m)), 64n) == 0n : Nat}

law pad_prefix:
  for +m: Spec.Bytes
  {List.take(&2, Word(8n), Sha256.pad(m), Spec.len(m)) == m : Spec.Bytes}

law pad_marker:
  for +m: Spec.Bytes
  {List.get(&2, Word(8n), Sha256.pad(m), Spec.len(m)) == Some{Spec.byte(128n)} : Maybe<&2, Word(8n)>}

# the last 8 bytes are the message's length in bits, modulo 2^64
law pad_length:
  for +m: Spec.Bytes
  {List.drop(&2, Word(8n), Sha256.pad(m), Nat.sub(Spec.len(Sha256.pad(m)), 8n))
    == Spec.be(8n, Nat.mul(8n, Spec.len(m))) : Spec.Bytes}

# the bytes between the marker and the length are all zero
law pad_zeros:
  for +m: Spec.Bytes
  {List.take(&2, Word(8n), List.drop(&2, Word(8n), Sha256.pad(m), 1n+Spec.len(m)),
      Nat.sub(Nat.sub(Spec.len(Sha256.pad(m)), Spec.len(m)), 9n))
    == List.replicate(Word(8n), Nat.sub(Nat.sub(Spec.len(Sha256.pad(m)), Spec.len(m)), 9n), Spec.byte(0n))
    : Spec.Bytes}

law pad_minimal:
  for +m: Spec.Bytes
  {Nat.is_le(9n, Nat.sub(Spec.len(Sha256.pad(m)), Spec.len(m))) == True{} : Bool}
  & {Nat.is_le(Nat.sub(Spec.len(Sha256.pad(m)), Spec.len(m)), 72n) == True{} : Bool}

law pad_injective:
  for +a: Spec.Bytes
  for +b: Spec.Bytes
  {Sha256.pad(a) == Sha256.pad(b) : Spec.Bytes} -> {a == b : Spec.Bytes}

# The pieces, for every input.

law schedule_prefix:
  for +block: Spec.Bytes
  {Spec.len(block) == 64n : Nat}
  -> {List.take(&2, U32, Sha256.schedule(Sha256.words(block)), 16n) == Spec.be_words(block) : List<&2, U32>}

law encode_roundtrip:
  for +d: Sha256.Digest
  {Sha256.decode(Sha256.encode(d)) == d : Sha256.Digest}
