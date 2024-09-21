.PHONY: docs-serve
docs-serve:
	hugo -s docs/website serve

.PHONY: docs-build
docs-build:
	hugo -s docs/website

# Ideally, this should be done only in the remote CI environment with a certain
# update cadence/rhythm.
.PHONY: update
update:
	npins update

# Ideally this should be done before committing.
.PHONY: format
format:
	treefmt
