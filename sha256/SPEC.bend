# What LAWS.bend states SHA-256 against: byte helpers and NIST's published
# vectors. Owned by the owner; never edited to make a proof go through.

import Base

def Bytes() -> Data:
  List<&2, Word(8n)>

def len(xs: Bytes) -> Nat:
  List.length(&2, Word(8n), xs)

# the low n bits of k; a Word holds its lowest bit first
def bits(n: Nat, +k: Nat) -> Word(n):
  match n:
    case 0n:
      WNil{}
    case 1n+p:
      WCon{Nat.is_eq(Nat.mod(k, 2n), 1n), bits(p, Nat.div(k, 2n))}

def byte(k: Nat) -> Word(8n):
  bits(8n, k)

# the low 8k bits of n as k bytes, most significant first
def be(k: Nat, +n: Nat) -> Bytes:
  match k:
    case 0n:
      Nil{}
    case 1n+p:
      List.append(&2, Word(8n), be(p, Nat.div(n, 256n)), [byte(n)])

def cat(m: Nat, -n: Nat, lo: Word(m), hi: Word(n)) -> Word(Nat.add(m, n)):
  match m:
    case 0n:
      hi
    case 1n+p:
      match lo:
        case WCon{b, t}:
          WCon{b, cat(p, n, t, hi)}

# the word whose bytes, most significant first, are a b c d
def be32(a: Word(8n), b: Word(8n), c: Word(8n), d: Word(8n)) -> U32:
  U32{cat(8n, 24n, d, cat(8n, 16n, c, cat(8n, 8n, b, a)))}

def be_words(xs: Bytes) -> List<&2, U32>:
  match xs:
    case a <> b <> c <> d <> t:
      be32(a, b, c, d) <> be_words(t)
    case _:
      Nil{}

# lowercase hex digits only
def nibble.pick(+c: Nat, digit: Bool) -> Nat:
  match digit:
    case True{}:
      Nat.sub(c, 48n)
    case False{}:
      Nat.sub(c, 87n)

def nibble(c: Char) -> Nat:
  +n = U32.to_nat(Char.to_u32(c))
  nibble.pick(n, Nat.is_lt(n, 58n))

def hex(s: String) -> Bytes:
  match s:
    case SCon{h, SCon{l, t}}:
      byte(Nat.add(Nat.mul(nibble(h), 16n), nibble(l))) <> hex(t)
    case _:
      Nil{}

def ascii(s: String) -> Bytes:
  match s:
    case SNil{}:
      Nil{}
    case SCon{c, t}:
      byte(U32.to_nat(Char.to_u32(c))) <> ascii(t)

# NIST example values for SHA-256, csrc.nist.gov/projects/
# cryptographic-standards-and-guidelines/example-values

def abc() -> Bytes:
  ascii("abc")

def abc_md() -> Bytes:
  hex("ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad")

def two_block() -> Bytes:
  ascii("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq")

def two_block_md() -> Bytes:
  hex("248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1")

# CAVP SHA256ShortMsg.rsp, csrc.nist.gov/projects/
# cryptographic-algorithm-validation-program/secure-hashing. Lengths in bits:
# 440 and 448 sit where the length field stops fitting in the last block.

def empty() -> Bytes:
  Nil{}

def empty_md() -> Bytes:
  hex("e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")

def short_440() -> Bytes:
  hex("3ebfb06db8c38d5ba037f1363e118550aad94606e26835a01af05078533cc25f2f39573c04b632f62f68c294ab31f2a3e2a1a0d8c2be51")

def short_440_md() -> Bytes:
  hex("6595a2ef537a69ba8583dfbf7f5bec0ab1f93ce4c8ee1916eff44a93af5749c4")

def short_448() -> Bytes:
  hex("2d52447d1244d2ebc28650e7b05654bad35b3a68eedc7f8515306b496d75f3e73385dd1b002625024b81a02f2fd6dffb6e6d561cb7d0bd7a")

def short_448_md() -> Bytes:
  hex("cfb88d6faf2de3a69d36195acec2e255e2af2b7d933997f348e09f6ce5758360")

def short_504() -> Bytes:
  hex("e2f76e97606a872e317439f1a03fcd92e632e5bd4e7cbc4e97f1afc19a16fde92d77cbe546416b51640cddb92af996534dfd81edb17c4424cf1ac4d75aceeb")

def short_504_md() -> Bytes:
  hex("18041bd4665083001fba8c5411d2d748e8abbfdcdfd9218cb02b68a78e7d4c23")

def short_512() -> Bytes:
  hex("5a86b737eaea8ee976a0a24da63e7ed7eefad18a101c1211e2b3650c5187c2a8a650547208251f6d4237e661c7bf4c77f335390394c37fa1a9f9be836ac28509")

def short_512_md() -> Bytes:
  hex("42e61e174fbb3897d6dd6cef3dd2802fe67b331953b06114a65c772859dfc1aa")
