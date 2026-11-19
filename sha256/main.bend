# SHA-256, FIPS 180-4, for messages of whole bytes.

import Base
import ./SPEC.bend as Spec

type Digest is Data:
  Digest{h0: U32, h1: U32, h2: U32, h3: U32, h4: U32, h5: U32, h6: U32, h7: U32}

def hash(m: Spec.Bytes) -> Digest:
  ?TODO

def pad(m: Spec.Bytes) -> Spec.Bytes:
  ?TODO

def words(block: Spec.Bytes) -> List<&2, U32>:
  ?TODO

def schedule(w: List<&2, U32>) -> List<&2, U32>:
  ?TODO

# H0 through H7, each most significant byte first
def encode(d: Digest) -> Spec.Bytes:
  ?TODO

def decode(b: Spec.Bytes) -> Digest:
  ?TODO
