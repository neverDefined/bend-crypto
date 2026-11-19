export BEND_NO_TELEMETRY := 1

PROOFS := $(wildcard */PROOF.bend)

.PHONY: gate
gate:
	@test -n "$(PROOFS)"
	@for f in $(PROOFS); do echo "$$f"; bend "$$f" --verdict || exit 1; done
