#!/usr/bin/env bash

workflow=$1
shift 1

# Just mind the ordering of the search paths here, the extra `extra-config` is
# just the fallback value. As of Nix v2.18, there is a first-come first-serve
# precedence so if the user sets the `extra-config` Nix path, it should
# override the default.

# shellcheck disable=SC2068
nix-build -A config.system.build.vm -k \
    --argstr workflow "$workflow" \
    @datadir@/@projectname@/configuration.nix \
    @inputsArgs@ \
    $@ \
    -I extra-config=@datadir@/@projectname@ \
    ${NIX_EXTRA_ARGS[@]}
