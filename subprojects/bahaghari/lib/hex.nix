# A small utility library for manipulating hexadecimal numbers. It's made in 15
# minutes with a bunch of duct tape on it but it's working for its intended
# purpose.
{ pkgs, lib }:

rec {
  inherit (pkgs.lib.trivial) toHexString;

  # A variant of `lib.lists.range` function just with hexadecimal digits.
  range = first: last: builtins.map (n: toHexString n) (lib.lists.range first last);
}
