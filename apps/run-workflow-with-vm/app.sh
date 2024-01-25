#!/usr/bin/env bash

workflow=$1
shift 1
nix-build -A config.system.build.vm -k \
    --argstr workflow "$workflow" \
    @datadir@/@projectname@/configuration.nix \
    @inputsArgs@ \
    $@ \
    ${NIX_EXTRA_ARGS[@]}
