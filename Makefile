export BEND_NO_TELEMETRY := 1

.PHONY: gate
gate:
	bend PROOF.bend --verdict
