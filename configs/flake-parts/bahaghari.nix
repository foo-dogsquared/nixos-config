# Bahaghari's subproject.
{ ... }:

{
  # We'll simply copy over Bahaghari's default exports.
  flake = import ../../subprojects/bahaghari { };
}
