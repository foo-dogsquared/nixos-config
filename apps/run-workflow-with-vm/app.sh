#!/usr/bin/env bash

nix-build -A config.system.build.vm -k \
    --argstr workflow "$1" \
    @datadir@/@projectname@/configuration.nix \
    @inputsArgs@ \
    ${NIX_EXTRA_ARGS[@]}
