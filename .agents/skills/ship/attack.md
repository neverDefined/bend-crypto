# Attack round

You have code and the task it implements. Break it; do not review it.
Report only what a test or script reproduces, each with its command and
output on the branch. Then, separately, what you suspect but could not
reproduce.

Try at least these, where they apply:

- Exhaustion: the cheapest way to deny service to others, counted in
  requests per second, addresses or bytes. IPv6 prefixes are cheap: one /48
  holds 65,536 /64s.
- Protocol edges: every version, method and framing the server accepts,
  request smuggling, partial reads and writes, slow and silent peers.
- Keys and signatures: every public function that verifies checks its own
  inputs (key validity, small-order points, encodings), even when today's
  callers check first.
- Browser policy: headers against the repo's other web servers (CSP,
  framing, cookies, content types).
- Cancel and shutdown: nothing is held past its bound when a peer leaves or
  the process stops.
- Parsers of untrusted input: a fuzz target exists and has run.

Your task lists anything the repo's rules add.
