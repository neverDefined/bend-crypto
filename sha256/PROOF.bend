import Base
import ./main.bend as Sha256
import ./SPEC.bend as Spec
import ./LAWS.bend as Laws

def framed(m: Spec.Bytes, k: Nat, x: Nat) -> Spec.Bytes:
  List.append(&2, Word(8n), Sha256.pad.body(m, k), Spec.be(8n, x))

def zeros_framed(q: Nat, x: Nat) -> Spec.Bytes:
  List.append(&2, Word(8n), Sha256.pad.zeros(q), Spec.be(8n, x))

def quarter(n: Nat) -> Nat:
  match n:
    case 0n:
      0n
    case 1n:
      0n
    case 2n:
      0n
    case 3n:
      0n
    case 4n+p:
      1n+quarter(p)

def words_be(+xs: Spec.Bytes) -> {Sha256.words(xs) == Spec.be_words(xs) : List<&2, U32>}:
  match xs:
    case Nil{}:
      {==}
    case a <> Nil{}:
      {==}
    case a <> b <> Nil{}:
      {==}
    case a <> b <> c <> Nil{}:
      {==}
    case a <> b <> c <> d <> t:
      %words_be(t) : {Spec.be32(a, b, c, d) <> Sha256.words(t)
        == Spec.be32(a, b, c, d) <> _ : List<&2, U32>}
      {==}

def words_length(+xs: Spec.Bytes) ->
  {List.length(&2, U32, Sha256.words(xs)) == quarter(Spec.len(xs)) : Nat}:
  match xs:
    case Nil{}:
      {==}
    case a <> Nil{}:
      {==}
    case a <> b <> Nil{}:
      {==}
    case a <> b <> c <> Nil{}:
      {==}
    case a <> b <> c <> d <> t:
      %words_length(t) : {1n+List.length(&2, U32, Sha256.words(t)) == 1n+_ : Nat}
      {==}

def take_append(+xs: List<&2, U32>, +ys: List<&2, U32>) ->
  {List.take(&2, U32, List.append(&2, U32, xs, ys), List.length(&2, U32, xs))
    == xs : List<&2, U32>}:
  match xs:
    case Nil{}:
      match ys:
        case Nil{}:
          {==}
        case h <> t:
          {==}
    case h <> t:
      %take_append(t, ys) :
        {h <> List.take(&2, U32, List.append(&2, U32, t, ys), List.length(&2, U32, t))
        == h <> _ : List<&2, U32>}
      {==}

def disc(n: Nat) -> Type:
  match n:
    case 0n:
      Unit
    case 1n+p:
      Empty

def add_succ(a: Nat, -b: Nat) -> {Nat.add(a, 1n+b) == 1n+Nat.add(a, b) : Nat}:
  match a:
    case 0n:
      {==}
    case 1n+p:
      %add_succ(p, b) : {1n+Nat.add(p, 1n+b) == 1n+_ : Nat}
      {==}

# one more byte in the block moves one count from k to r
def count_on(p: Nat, -r: Nat, h: {1n+Nat.add(p, r) == 63n : Nat}) ->
  {Nat.add(p, 1n+r) == 63n : Nat}:
  Equal.trans(Nat, Nat.add(p, 1n+r), 1n+Nat.add(p, r), 63n, add_succ(p, r), h)

def le_zero(n: Nat) -> {Nat.is_le(0n, n) == True{} : Bool}:
  match n:
    case 0n:
      {==}
    case 1n+p:
      {==}

def le_add8(q: Nat, -r: Nat) -> {Nat.is_le(q, 8n+Nat.add(q, r)) == True{} : Bool}:
  match q:
    case 0n:
      {==}
    case 1n+p:
      le_add8(p, r)

def sub_zero(n: Nat) -> {Nat.sub(n, 0n) == n : Nat}:
  match n:
    case 0n:
      {==}
    case 1n+p:
      {==}

def len_app8(+xs: Spec.Bytes, -x: Nat) ->
  {Spec.len(List.append(&2, Word(8n), xs, Spec.be(8n, x))) == 8n+Spec.len(xs) : Nat}:
  match xs:
    case Nil{}:
      {==}
    case h <> t:
      %len_app8(t, x) : {1n+Spec.len(List.append(&2, Word(8n), t, Spec.be(8n, x))) == 1n+_ : Nat}
      {==}

def len_app8_add(+xs: Spec.Bytes, -x: Nat) ->
  {Spec.len(List.append(&2, Word(8n), xs, Spec.be(8n, x))) == Nat.add(Spec.len(xs), 8n) : Nat}:
  match xs:
    case Nil{}:
      {==}
    case h <> t:
      %len_app8_add(t, x) : {1n+Spec.len(List.append(&2, Word(8n), t, Spec.be(8n, x)))
        == 1n+_ : Nat}
      {==}

def drop_app(+xs: Spec.Bytes, -x: Nat) ->
  {List.drop(&2, Word(8n), List.append(&2, Word(8n), xs, Spec.be(8n, x)), Spec.len(xs))
    == Spec.be(8n, x) : Spec.Bytes}:
  match xs:
    case Nil{}:
      {==}
    case h <> t:
      drop_app(t, x)

def body_prefix(+m: Spec.Bytes, +k: Nat, -ys: Spec.Bytes) ->
  {List.take(&2, Word(8n), List.append(&2, Word(8n), Sha256.pad.body(m, k), ys), Spec.len(m))
    == m : Spec.Bytes}:
  match m:
    case Nil{}:
      {==}
    case h <> t:
      match k:
        case 0n:
          %body_prefix(t, 63n, ys) :
            {h <> List.take(&2, Word(8n), List.append(&2, Word(8n), Sha256.pad.body(t, 63n), ys),
              Spec.len(t))
            == h <> _ : Spec.Bytes}
          {==}
        case 1n+p:
          %body_prefix(t, p, ys) :
            {h <> List.take(&2, Word(8n), List.append(&2, Word(8n), Sha256.pad.body(t, p), ys),
              Spec.len(t))
            == h <> _ : Spec.Bytes}
          {==}

def body_marker(+m: Spec.Bytes, +k: Nat, -ys: Spec.Bytes) ->
  {List.get(&2, Word(8n), List.append(&2, Word(8n), Sha256.pad.body(m, k), ys), Spec.len(m))
    == Some{Spec.byte(128n)} : Maybe<&2, Word(8n)>}:
  match m:
    case Nil{}:
      {==}
    case h <> t:
      match k:
        case 0n:
          body_marker(t, 63n, ys)
        case 1n+p:
          body_marker(t, p, ys)

def remainder(n: Nat, k: Nat, d: Nat, r: Nat) -> Nat:
  Pair.snd(Nat, Nat, Nat.divmod.go(n, k, d, r))

# The walk mirrors Nat.divmod.go by 64: k counts down to the block's end and r
# counts the bytes already in it, so the remainder is 0 exactly when the last
# byte closes a block.
def tail_walk(q: Nat, -d: Nat, -r: Nat) ->
  {remainder(1n+Nat.add(Spec.len(Sha256.pad.zeros(q)), 8n), 8n+q, d, r) == 0n : Nat}:
  match q:
    case 0n:
      {==}
    case 1n+p:
      tail_walk(p, d, 1n+r)

def body_walk(+m: Spec.Bytes, +k: Nat, -r: Nat, -d: Nat, h: {Nat.add(k, r) == 63n : Nat}) ->
  {remainder(Nat.add(Spec.len(Sha256.pad.body(m, k)), 8n), k, d, r) == 0n : Nat}:
  match m:
    case Nil{}:
      match k:
        case 0n:
          %Equal.sym(Nat, r, 63n, h) : {remainder(64n, _, 1n+d, 0n) == 0n : Nat}
          {==}
        case 1n:
          %Equal.sym(Nat, 1n+r, 63n, h) : {remainder(64n, _, 1n+d, 0n) == 0n : Nat}
          {==}
        case 2n:
          %Equal.sym(Nat, 2n+r, 63n, h) : {remainder(64n, _, 1n+d, 0n) == 0n : Nat}
          {==}
        case 3n:
          %Equal.sym(Nat, 3n+r, 63n, h) : {remainder(64n, _, 1n+d, 0n) == 0n : Nat}
          {==}
        case 4n:
          %Equal.sym(Nat, 4n+r, 63n, h) : {remainder(64n, _, 1n+d, 0n) == 0n : Nat}
          {==}
        case 5n:
          %Equal.sym(Nat, 5n+r, 63n, h) : {remainder(64n, _, 1n+d, 0n) == 0n : Nat}
          {==}
        case 6n:
          %Equal.sym(Nat, 6n+r, 63n, h) : {remainder(64n, _, 1n+d, 0n) == 0n : Nat}
          {==}
        case 7n:
          %Equal.sym(Nat, 7n+r, 63n, h) : {remainder(64n, _, 1n+d, 0n) == 0n : Nat}
          {==}
        case 8n+q:
          tail_walk(q, d, r)
    case y <> t:
      match k:
        case 0n:
          %Equal.sym(Nat, r, 63n, h) :
            {remainder(Nat.add(Spec.len(Sha256.pad.body(t, 63n)), 8n), _, 1n+d, 0n)
            == 0n : Nat}
          body_walk(t, 63n, 0n, 1n+d, {==})
        case 1n+p:
          body_walk(t, p, 1n+r, d, count_on(p, r, h))

def aligned(+m: Spec.Bytes) -> {Nat.mod(Spec.len(Sha256.pad(m)), 64n) == 0n : Nat}:
  %Equal.sym(Nat, Spec.len(Sha256.pad(m)), Nat.add(Spec.len(Sha256.pad.body(m, 63n)), 8n),
    len_app8_add(Sha256.pad.body(m, 63n), Nat.mul(8n, Spec.len(m)))) : {Nat.mod(_, 64n) == 0n : Nat}
  body_walk(m, 63n, 0n, 0n, {==})

def tail_len(q: Nat, -x: Nat) ->
  {Spec.len(zeros_framed(q, x)) == 8n+q : Nat}:
  match q:
    case 0n:
      {==}
    case 1n+p:
      %tail_len(p, x) : {1n+Spec.len(zeros_framed(p, x)) == 1n+_ : Nat}
      {==}

def le_tail(+q: Nat, -r: Nat, h: {Nat.add(8n+q, r) == 63n : Nat}) ->
  {Nat.is_le(9n+q, 72n) == True{} : Bool}:
  %h : {Nat.is_le(q, _) == True{} : Bool}
  le_add8(q, r)

def minimal_tail(+q: Nat, -r: Nat, -x: Nat, h: {Nat.add(8n+q, r) == 63n : Nat}) ->
  {Nat.is_le(9n, 1n+Spec.len(zeros_framed(q, x))) == True{} : Bool}
  & {Nat.is_le(1n+Spec.len(zeros_framed(q, x)), 72n) == True{} : Bool}:
  %Equal.sym(Nat, Spec.len(zeros_framed(q, x)), 8n+q, tail_len(q, x)) :
    {Nat.is_le(9n, 1n+_) == True{} : Bool} & {Nat.is_le(1n+_, 72n) == True{} : Bool}
  (le_zero(q), le_tail(q, r, h))

def minimal_walk(+m: Spec.Bytes, +k: Nat, -r: Nat, -x: Nat, h: {Nat.add(k, r) == 63n : Nat}) ->
  {Nat.is_le(9n, Nat.sub(Spec.len(framed(m, k, x)), Spec.len(m))) == True{} : Bool}
  & {Nat.is_le(Nat.sub(Spec.len(framed(m, k, x)), Spec.len(m)), 72n) == True{} : Bool}:
  match m:
    case Nil{}:
      match k:
        case 0n:
          ({==}, {==})
        case 1n:
          ({==}, {==})
        case 2n:
          ({==}, {==})
        case 3n:
          ({==}, {==})
        case 4n:
          ({==}, {==})
        case 5n:
          ({==}, {==})
        case 6n:
          ({==}, {==})
        case 7n:
          ({==}, {==})
        case 8n+q:
          minimal_tail(q, r, x, h)
    case y <> t:
      match k:
        case 0n:
          minimal_walk(t, 63n, 0n, x, {==})
        case 1n+p:
          minimal_walk(t, p, 1n+r, x, count_on(p, r, h))

def zeros_take(q: Nat, -x: Nat) ->
  {List.take(&2, Word(8n), zeros_framed(q, x), q)
    == List.replicate(Word(8n), q, Spec.byte(0n)) : Spec.Bytes}:
  match q:
    case 0n:
      {==}
    case 1n+p:
      %zeros_take(p, x) : {Word.zero(8n) <> List.take(&2, Word(8n), zeros_framed(p, x), p)
        == Word.zero(8n) <> _ : Spec.Bytes}
      {==}

def zeros_tail(+q: Nat, -x: Nat) ->
  {List.take(&2, Word(8n), List.drop(&2, Word(8n), zeros_framed(q, x), 0n),
      Nat.sub(1n+Spec.len(zeros_framed(q, x)), 9n))
    == List.replicate(Word(8n), Nat.sub(1n+Spec.len(zeros_framed(q, x)), 9n), Spec.byte(0n))
    : Spec.Bytes}:
  match q:
    case 0n:
      {==}
    case 1n+p:
      %Equal.sym(Nat, Spec.len(zeros_framed(p, x)), 8n+p, tail_len(p, x)) :
        {List.take(&2, Word(8n), zeros_framed(1n+p, x), Nat.sub(2n+_, 9n))
          == List.replicate(Word(8n), Nat.sub(2n+_, 9n), Spec.byte(0n)) : Spec.Bytes}
      zeros_take(1n+p, x)

def zeros_walk(+m: Spec.Bytes, +k: Nat, -x: Nat) ->
  {List.take(&2, Word(8n), List.drop(&2, Word(8n), framed(m, k, x), 1n+Spec.len(m)),
      Nat.sub(Nat.sub(Spec.len(framed(m, k, x)), Spec.len(m)), 9n))
    == List.replicate(Word(8n), Nat.sub(Nat.sub(Spec.len(framed(m, k, x)), Spec.len(m)), 9n),
      Spec.byte(0n)) : Spec.Bytes}:
  match m:
    case Nil{}:
      match k:
        case 0n:
          {==}
        case 1n:
          {==}
        case 2n:
          {==}
        case 3n:
          {==}
        case 4n:
          {==}
        case 5n:
          {==}
        case 6n:
          {==}
        case 7n:
          {==}
        case 8n+q:
          zeros_tail(q, x)
    case y <> t:
      match k:
        case 0n:
          zeros_walk(t, 63n, x)
        case 1n+p:
          zeros_walk(t, p, x)

def head_or(xs: Spec.Bytes, d: Word(8n)) -> Word(8n):
  match xs:
    case Nil{}:
      d
    case h <> t:
      h

def head_nat(xs: Spec.Bytes) -> Nat:
  match xs:
    case Nil{}:
      0n
    case h <> t:
      Word.to_nat(8n, h)

def tail_eq(-xs: Spec.Bytes, -ys: Spec.Bytes, e: {xs == ys : Spec.Bytes}) ->
  {List.tail(&2, Word(8n), xs) == List.tail(&2, Word(8n), ys) : Spec.Bytes}:
  Equal.cong(Spec.Bytes, Spec.Bytes, l => List.tail(&2, Word(8n), l), xs, ys, e)

def short_clash.len(+t: Spec.Bytes, +k: Nat, e: {8n
  == 8n+Spec.len(Sha256.pad.body(t, k)) : Nat}) -> Empty:
  match t:
    case Nil{}:
      %e : disc(Nat.sub(_, 8n))
      Unit{}
    case z <> s:
      match k:
        case 0n:
          %e : disc(Nat.sub(_, 8n))
          Unit{}
        case 1n+p:
          %e : disc(Nat.sub(_, 8n))
          Unit{}

# the length field alone is too short to hold a body and its own field
def short_clash(+t: Spec.Bytes, +k: Nat, -x: Nat, -y: Nat,
  e: {Spec.be(8n, x) == framed(t, k, y) : Spec.Bytes}) -> Empty:
  -l = framed(t, k, y)
  el = Equal.cong(Spec.Bytes, Nat, xs => Spec.len(xs), Spec.be(8n, x), l, e)
  +b = Sha256.pad.body(t, k)
  short_clash.len(t, k, Equal.trans(Nat, 8n, Spec.len(l), 8n+Spec.len(b), el, len_app8(b, y)))

# zero padding never holds the marker a body ends with
def zeros_clash(+g: Nat, +t: Spec.Bytes, +k: Nat, -x: Nat, -y: Nat,
  e: {zeros_framed(g, x) == framed(t, k, y) : Spec.Bytes}) -> Empty:
  match g t:
    case 0n _:
      short_clash(t, k, x, y, e)
    case 1n+f Nil{}:
      %Equal.cong(Spec.Bytes, Nat, xs => head_nat(xs), zeros_framed(g, x),
        framed(t, k, y), e) : disc(_)
      Unit{}
    case 1n+f z <> s:
      match k:
        case 0n:
          zeros_clash(f, s, 63n, x, y, tail_eq(zeros_framed(g, x),
            framed(t, k, y), e))
        case 1n+p:
          zeros_clash(f, s, p, x, y, tail_eq(zeros_framed(g, x),
            framed(t, k, y), e))

def injective(+a: Spec.Bytes, +b: Spec.Bytes, +k: Nat, -x: Nat, -y: Nat,
  +e: {framed(a, k, x) == framed(b, k, y) : Spec.Bytes}) -> {a == b : Spec.Bytes}:
  match a b:
    case Nil{} Nil{}:
      {==}
    case Nil{} v <> t:
      match k:
        case 0n:
          Empty.absurd({Nil{} == v <> t : Spec.Bytes}, zeros_clash(Sha256.pad.gap(0n), t, 63n, x, y,
            tail_eq(framed(Nil{}, 0n, x), v <> framed(t, 63n, y), e)))
        case 1n+p:
          Empty.absurd({Nil{} == v <> t : Spec.Bytes}, zeros_clash(Sha256.pad.gap(1n+p), t, p, x, y,
            tail_eq(framed(Nil{}, 1n+p, x), v <> framed(t, p, y), e)))
    case u <> s Nil{}:
      match k:
        case 0n:
          Empty.absurd({u <> s == Nil{} : Spec.Bytes}, zeros_clash(Sha256.pad.gap(0n), s, 63n, y, x,
            tail_eq(framed(Nil{}, 0n, y), u <> framed(s, 63n, x),
              Equal.sym(Spec.Bytes, u <> framed(s, 63n, x), framed(Nil{}, 0n, y), e))))
        case 1n+p:
          Empty.absurd({u <> s == Nil{} : Spec.Bytes}, zeros_clash(Sha256.pad.gap(1n+p), s, p, y, x,
            tail_eq(framed(Nil{}, 1n+p, y), u <> framed(s, p, x),
              Equal.sym(Spec.Bytes, u <> framed(s, p, x), framed(Nil{}, 1n+p, y), e))))
    case u <> s v <> t:
      match k:
        case 0n:
          -l = {u <> framed(s, 63n, x) : Spec.Bytes}
          -r = {v <> framed(t, 63n, y) : Spec.Bytes}
          hu = Equal.cong(Spec.Bytes, Word(8n), xs => head_or(xs, u), l, r, e)
          hs = injective(s, t, 63n, x, y, tail_eq(l, r, e))
          %hs : {u <> s == v <> _ : Spec.Bytes}
          %hu : {u <> s == _ <> s : Spec.Bytes}
          {==}
        case 1n+p:
          -l = {u <> framed(s, p, x) : Spec.Bytes}
          -r = {v <> framed(t, p, y) : Spec.Bytes}
          hu = Equal.cong(Spec.Bytes, Word(8n), xs => head_or(xs, u), l, r, e)
          hs = injective(s, t, p, x, y, tail_eq(l, r, e))
          %hs : {u <> s == v <> _ : Spec.Bytes}
          %hu : {u <> s == _ <> s : Spec.Bytes}
          {==}

# a word survives encoding when its bits are known; a symbolic word does not
# reduce through Word.split
def word_roundtrip(+x: U32, -rest: Spec.Bytes) ->
  {Sha256.words(List.append(&2, Word(8n), Sha256.encode.word(x), rest))
    == x <> Sha256.words(rest) : List<&2, U32>}:
  match x:
    case U32{WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7,
      WCon{b8, WCon{b9, WCon{b10, WCon{b11, WCon{b12, WCon{b13, WCon{b14, WCon{b15,
      WCon{b16, WCon{b17, WCon{b18, WCon{b19, WCon{b20, WCon{b21, WCon{b22, WCon{b23,
      WCon{b24, WCon{b25, WCon{b26, WCon{b27, WCon{b28, WCon{b29, WCon{b30, WCon{b31, WNil{}
      }}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      {==}

def Laws.vector_empty():
  {==}

def Laws.vector_abc():
  {==}

def Laws.vector_two_block():
  {==}

def Laws.vector_440():
  {==}

def Laws.vector_448():
  {==}

def Laws.vector_504():
  {==}

def Laws.vector_512():
  {==}

def Laws.encode_roundtrip(d):
  match d:
    case Sha256.Digest{h0, h1, h2, h3, h4, h5, h6, h7}:
      -r8 = {Nil{} : Spec.Bytes}
      -r7 = List.append(&2, Word(8n), Sha256.encode.word(h7), r8)
      -r6 = List.append(&2, Word(8n), Sha256.encode.word(h6), r7)
      -r5 = List.append(&2, Word(8n), Sha256.encode.word(h5), r6)
      -r4 = List.append(&2, Word(8n), Sha256.encode.word(h4), r5)
      -r3 = List.append(&2, Word(8n), Sha256.encode.word(h3), r4)
      -r2 = List.append(&2, Word(8n), Sha256.encode.word(h2), r3)
      -r1 = List.append(&2, Word(8n), Sha256.encode.word(h1), r2)
      -r0 = List.append(&2, Word(8n), Sha256.encode.word(h0), r1)
      %Equal.sym(List<&2, U32>, Sha256.words(r0), h0 <> Sha256.words(r1), word_roundtrip(h0, r1)) :
        {Sha256.decode.go(_) == Sha256.Digest{h0, h1, h2, h3, h4, h5, h6, h7} : Sha256.Digest}
      %Equal.sym(List<&2, U32>, Sha256.words(r1), h1 <> Sha256.words(r2), word_roundtrip(h1, r2)) :
        {Sha256.decode.go(h0 <> _) == Sha256.Digest{h0, h1, h2, h3, h4, h5, h6, h7} : Sha256.Digest}
      %Equal.sym(List<&2, U32>, Sha256.words(r2), h2 <> Sha256.words(r3), word_roundtrip(h2, r3)) :
        {Sha256.decode.go(h0 <> h1 <> _)
          == Sha256.Digest{h0, h1, h2, h3, h4, h5, h6, h7} : Sha256.Digest}
      %Equal.sym(List<&2, U32>, Sha256.words(r3), h3 <> Sha256.words(r4), word_roundtrip(h3, r4)) :
        {Sha256.decode.go(h0 <> h1 <> h2 <> _)
          == Sha256.Digest{h0, h1, h2, h3, h4, h5, h6, h7} : Sha256.Digest}
      %Equal.sym(List<&2, U32>, Sha256.words(r4), h4 <> Sha256.words(r5), word_roundtrip(h4, r5)) :
        {Sha256.decode.go(h0 <> h1 <> h2 <> h3 <> _)
          == Sha256.Digest{h0, h1, h2, h3, h4, h5, h6, h7} : Sha256.Digest}
      %Equal.sym(List<&2, U32>, Sha256.words(r5), h5 <> Sha256.words(r6), word_roundtrip(h5, r6)) :
        {Sha256.decode.go(h0 <> h1 <> h2 <> h3 <> h4 <> _)
          == Sha256.Digest{h0, h1, h2, h3, h4, h5, h6, h7} : Sha256.Digest}
      %Equal.sym(List<&2, U32>, Sha256.words(r6), h6 <> Sha256.words(r7), word_roundtrip(h6, r7)) :
        {Sha256.decode.go(h0 <> h1 <> h2 <> h3 <> h4 <> h5 <> _)
          == Sha256.Digest{h0, h1, h2, h3, h4, h5, h6, h7} : Sha256.Digest}
      %Equal.sym(List<&2, U32>, Sha256.words(r7), h7 <> Sha256.words(r8), word_roundtrip(h7, r8)) :
        {Sha256.decode.go(h0 <> h1 <> h2 <> h3 <> h4 <> h5 <> h6 <> _)
          == Sha256.Digest{h0, h1, h2, h3, h4, h5, h6, h7} : Sha256.Digest}
      {==}

def Laws.schedule_prefix(block, e):
  +w = Sha256.words(block)
  n16 = Equal.trans(Nat, List.length(&2, U32, w), quarter(Spec.len(block)), 16n,
    words_length(block), Equal.cong(Nat, Nat, n => quarter(n), Spec.len(block), 64n, e))
  %n16 : {List.take(&2, U32, Sha256.schedule(w), _) == Spec.be_words(block) : List<&2, U32>}
  %words_be(block) : {List.take(&2, U32, Sha256.schedule(w), List.length(&2, U32, w))
    == _ : List<&2, U32>}
  take_append(w, Sha256.schedule.extend(48n, w))

def Laws.pad_aligned(m):
  aligned(m)

def Laws.pad_prefix(m):
  body_prefix(m, 63n, Spec.be(8n, Nat.mul(8n, Spec.len(m))))

def Laws.pad_marker(m):
  body_marker(m, 63n, Spec.be(8n, Nat.mul(8n, Spec.len(m))))

def Laws.pad_length(m):
  %Equal.sym(Nat, Spec.len(Sha256.pad(m)), 8n+Spec.len(Sha256.pad.body(m, 63n)),
    len_app8(Sha256.pad.body(m, 63n), Nat.mul(8n, Spec.len(m)))) :
    {List.drop(&2, Word(8n), Sha256.pad(m), Nat.sub(_, 8n))
      == Spec.be(8n, Nat.mul(8n, Spec.len(m))) : Spec.Bytes}
  %Equal.sym(Nat, Nat.sub(Spec.len(Sha256.pad.body(m, 63n)), 0n), Spec.len(Sha256.pad.body(m, 63n)),
    sub_zero(Spec.len(Sha256.pad.body(m, 63n)))) :
    {List.drop(&2, Word(8n), Sha256.pad(m), _)
      == Spec.be(8n, Nat.mul(8n, Spec.len(m))) : Spec.Bytes}
  drop_app(Sha256.pad.body(m, 63n), Nat.mul(8n, Spec.len(m)))

def Laws.pad_zeros(m):
  zeros_walk(m, 63n, Nat.mul(8n, Spec.len(m)))

def Laws.pad_minimal(m):
  minimal_walk(m, 63n, 0n, Nat.mul(8n, Spec.len(m)), {==})

def Laws.pad_injective(a, b, e):
  injective(a, b, 63n, Nat.mul(8n, Spec.len(a)), Nat.mul(8n, Spec.len(b)), e)
