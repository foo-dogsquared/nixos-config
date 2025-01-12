# No, this is not a flake of the library set, it is a library subset for
# flake-related shtick. This should be used VERY RARELY in most parts of the
# configuration because they are set up to be usable both in flakes and
# flake-less environment.
#
# Take note it has a very strict design constraint of not relying on the
# `inputs` attribute of the flake output. Instead, we're relying on the
# builtins and the flake lockfile for this.
#
# Because Nix under the hood is a bit of a mess especially relating with
# flakes, we'll have to thoroughly document which versions this is working. So
# far, it is working on flake format version 7. AAAAAND also because apparently
# it requires flakes to be enabled to use `builtins.fetchTree`, this is pretty
# much a flakes-only subset.
#
# If anything else is pretty much in despair, we could always ste- I mean...
# copy edolstra's flake-compat implementation.
rec {
  importFlakeMetadata = flakeLockfile:
    builtins.fromJSON (builtins.readFile flakeLockfile);

  fetchTree = metadata: inputName:
    builtins.fetchTree metadata.nodes.${inputName}.locked;

  fetchInput = metadata: inputName: (fetchTree metadata inputName).outPath;
}
