# SHA-256, FIPS 180-4, for messages of whole bytes.

import Base
import ./SPEC.bend as Spec

type Digest is Data:
  Digest{h0: U32, h1: U32, h2: U32, h3: U32, h4: U32, h5: U32, h6: U32, h7: U32}

def Word.split.con(-p: Nat, -n: Nat, b: Bool, r: Word(p) & Word(n)) -> Word(1n+p) & Word(n):
  (lo, hi) = r
  (WCon{b, lo}, hi)

def Word.split(m: Nat, -n: Nat, w: Word(Nat.add(m, n))) -> Word(m) & Word(n):
  match m:
    case 0n:
      (WNil{}, w)
    case 1n+p:
      match w:
        case WCon{b, t}:
          Word.split.con(p, n, b, Word.split(p, n, t))

def Word.rotr.cat(-k: Nat, j: Nat, r: Word(k) & Word(j)) -> Word(Nat.add(j, k)):
  (lo, hi) = r
  Spec.cat(j, k, hi, lo)

def Word.rotr(+k: Nat, +j: Nat, w: Word(Nat.add(k, j))) -> Word(Nat.add(j, k)):
  Word.rotr.cat(k, j, Word.split(k, j, w))

def Word.shr.cat(k: Nat, j: Nat, r: Word(k) & Word(j)) -> Word(Nat.add(j, k)):
  (lo, hi) = r
  Spec.cat(j, k, hi, Word.zero(k))

def Word.shrn(+k: Nat, +j: Nat, w: Word(Nat.add(k, j))) -> Word(Nat.add(j, k)):
  Word.shr.cat(k, j, Word.split(k, j, w))

def big_sigma0(x: U32) -> U32:
  match x:
    case U32{+w}:
      U32{Word.xor(32n, Word.rotr(2n, 30n, w),
        Word.xor(32n, Word.rotr(13n, 19n, w), Word.rotr(22n, 10n, w)))}

def big_sigma1(x: U32) -> U32:
  match x:
    case U32{+w}:
      U32{Word.xor(32n, Word.rotr(6n, 26n, w),
        Word.xor(32n, Word.rotr(11n, 21n, w), Word.rotr(25n, 7n, w)))}

def small_sigma0(x: U32) -> U32:
  match x:
    case U32{+w}:
      U32{Word.xor(32n, Word.rotr(7n, 25n, w),
        Word.xor(32n, Word.rotr(18n, 14n, w), Word.shrn(3n, 29n, w)))}

def small_sigma1(x: U32) -> U32:
  match x:
    case U32{+w}:
      U32{Word.xor(32n, Word.rotr(17n, 15n, w),
        Word.xor(32n, Word.rotr(19n, 13n, w), Word.shrn(10n, 22n, w)))}

def ch(+x: U32, y: U32, z: U32) -> U32:
  U32.xor(U32.and(x, y), U32.and(U32.not(x), z))

def maj(+x: U32, +y: U32, +z: U32) -> U32:
  U32.xor(U32.and(x, y), U32.xor(U32.and(x, z), U32.and(y, z)))

# K, in decimal: Bend has no hexadecimal literal
def round_constants() -> List<&2, U32>:
  [
    1116352408, 1899447441, 3049323471, 3921009573,
    961987163, 1508970993, 2453635748, 2870763221,
    3624381080, 310598401, 607225278, 1426881987,
    1925078388, 2162078206, 2614888103, 3248222580,
    3835390401, 4022224774, 264347078, 604807628,
    770255983, 1249150122, 1555081692, 1996064986,
    2554220882, 2821834349, 2952996808, 3210313671,
    3336571891, 3584528711, 113926993, 338241895,
    666307205, 773529912, 1294757372, 1396182291,
    1695183700, 1986661051, 2177026350, 2456956037,
    2730485921, 2820302411, 3259730800, 3345764771,
    3516065817, 3600352804, 4094571909, 275423344,
    430227734, 506948616, 659060556, 883997877,
    958139571, 1322822218, 1537002063, 1747873779,
    1955562222, 2024104815, 2227730452, 2361852424,
    2428436474, 2756734187, 3204031479, 3329325298
  ]

# H(0), in decimal like K
def initial_hash() -> Digest:
  Digest{1779033703, 3144134277, 1013904242, 2773480762,
    1359893119, 2600822924, 528734635, 1541459225}

def round(k: U32, w: U32, st: Digest) -> Digest:
  match st:
    case Digest{+a, +b, +c, d, +e, +f, +g, h}:
      +t1 = U32.add(U32.add(U32.add(h, big_sigma1(e)), U32.add(ch(e, f, g), k)), w)
      t2 = U32.add(big_sigma0(a), maj(a, b, c))
      Digest{U32.add(t1, t2), a, b, c, U32.add(d, t1), e, f, g}

def rounds(ks: List<&2, U32>, ws: List<&2, U32>, st: Digest) -> Digest:
  match ks ws:
    case k <> kt w <> wt:
      rounds(kt, wt, round(k, w, st))
    case _ _:
      st

def Digest.add(x: Digest, y: Digest) -> Digest:
  match x y:
    case Digest{a0, b0, c0, d0, e0, f0, g0, h0} Digest{a1, b1, c1, d1, e1, f1, g1, h1}:
      Digest{U32.add(a0, a1), U32.add(b0, b1), U32.add(c0, c1), U32.add(d0, d1),
        U32.add(e0, e1), U32.add(f0, f1), U32.add(g0, g1), U32.add(h0, h1)}

def compress(+st: Digest, ws: List<&2, U32>) -> Digest:
  Digest.add(st, rounds(round_constants, ws, st))

def pad.zeros(n: Nat) -> Spec.Bytes:
  match n:
    case 0n:
      Nil{}
    case 1n+p:
      Word.zero(8n) <> pad.zeros(p)

# k + 1 bytes are left in the block, and the marker and 8-byte length must end
# a block
def pad.gap(k: Nat) -> Nat:
  match k:
    case 0n:
      56n
    case 1n:
      57n
    case 2n:
      58n
    case 3n:
      59n
    case 4n:
      60n
    case 5n:
      61n
    case 6n:
      62n
    case 7n:
      63n
    case 8n+p:
      p

# k counts down the bytes left in the current block, so no division by 64 runs
# on the message's length
def pad.body(m: Spec.Bytes, k: Nat) -> Spec.Bytes:
  match m:
    case Nil{}:
      Spec.byte(128n) <> pad.zeros(pad.gap(k))
    case h <> t:
      match k:
        case 0n:
          h <> pad.body(t, 63n)
        case 1n+p:
          h <> pad.body(t, p)

def pad.go(+m: Spec.Bytes) -> Spec.Bytes:
  List.append(&2, Word(8n), pad.body(m, 63n), Spec.be(8n, Nat.mul(8n, Spec.len(m))))

def pad(m: Spec.Bytes) -> Spec.Bytes:
  pad.go(m)

def words(block: Spec.Bytes) -> List<&2, U32>:
  match block:
    case a <> b <> c <> d <> t:
      Spec.be32(a, b, c, d) <> words(t)
    case _:
      Nil{}

def schedule.extend(n: Nat, +w: List<&2, U32>) -> List<&2, U32>:
  match n:
    case 0n:
      Nil{}
    case 1n+p:
      match w:
        case w0 <> w1 <> w2 <> w3 <> w4 <> w5 <> w6 <> w7 <>
          w8 <> w9 <> w10 <> w11 <> w12 <> w13 <> w14 <> w15 <> rest:
          +x = U32.add(U32.add(small_sigma1(w14), w9), U32.add(small_sigma0(w1), w0))
          x <> schedule.extend(p, w1 <> w2 <> w3 <> w4 <> w5 <> w6 <> w7 <> w8 <>
            w9 <> w10 <> w11 <> w12 <> w13 <> w14 <> w15 <> [x])
        case _:
          Nil{}

def schedule.go(+w: List<&2, U32>) -> List<&2, U32>:
  List.append(&2, U32, w, schedule.extend(48n, w))

def schedule(w: List<&2, U32>) -> List<&2, U32>:
  schedule.go(w)

def hash.go(ws: List<&2, U32>, st: Digest) -> Digest:
  match ws:
    case w0 <> w1 <> w2 <> w3 <> w4 <> w5 <> w6 <> w7 <>
      w8 <> w9 <> w10 <> w11 <> w12 <> w13 <> w14 <> w15 <> rest:
      hash.go(rest, compress(st, schedule([w0, w1, w2, w3, w4, w5, w6, w7,
        w8, w9, w10, w11, w12, w13, w14, w15])))
    case _:
      st

def hash(m: Spec.Bytes) -> Digest:
  hash.go(words(pad(m)), initial_hash)

def encode.word.hi(b0: Word(8n), b1: Word(8n), r: Word(8n) & Word(8n)) -> Spec.Bytes:
  (b2, b3) = r
  [b3, b2, b1, b0]

def encode.word.mid(b0: Word(8n), r: Word(8n) & Word(16n)) -> Spec.Bytes:
  (b1, t) = r
  encode.word.hi(b0, b1, Word.split(8n, 8n, t))

def encode.word.lo(r: Word(8n) & Word(24n)) -> Spec.Bytes:
  (b0, t) = r
  encode.word.mid(b0, Word.split(8n, 16n, t))

def encode.word(x: U32) -> Spec.Bytes:
  match x:
    case U32{w}:
      encode.word.lo(Word.split(8n, 24n, w))

# H0 through H7, each most significant byte first
def encode(d: Digest) -> Spec.Bytes:
  match d:
    case Digest{h0, h1, h2, h3, h4, h5, h6, h7}:
      List.concat(&2, Word(8n), [encode.word(h0), encode.word(h1), encode.word(h2),
        encode.word(h3), encode.word(h4), encode.word(h5), encode.word(h6), encode.word(h7)])

def decode.go(ws: List<&2, U32>) -> Digest:
  match ws:
    case h0 <> h1 <> h2 <> h3 <> h4 <> h5 <> h6 <> h7 <> _:
      Digest{h0, h1, h2, h3, h4, h5, h6, h7}
    case _:
      Digest{0, 0, 0, 0, 0, 0, 0, 0}

def decode(b: Spec.Bytes) -> Digest:
  decode.go(words(b))
