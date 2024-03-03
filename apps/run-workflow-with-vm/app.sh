#!/usr/bin/env bash

workflow=$1
shift 1

# shellcheck disable=SC2068
nix-build -A config.system.build.vm -k \
    --argstr workflow "$workflow" \
    @datadir@/@projectname@/configuration.nix \
    @inputsArgs@ \
    $@ \
    -I extra-config=@datadir@/@projectname@ \
    ${NIX_EXTRA_ARGS[@]}
