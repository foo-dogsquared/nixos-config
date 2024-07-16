.PHONY: docs-serve
docs-serve:
	hugo -s docs serve

.PHONY: docs-build
docs-build:
	hugo -s docs

# Ideally, this should be done only in the remote CI environment with a certain
# update cadence/rhythm.
.PHONY: update
update:
	npins update
