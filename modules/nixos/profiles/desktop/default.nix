# A common profile for desktop systems. Most of the configurations featured
# here should be enough in common to the typical desktop setups found on
# non-NixOS systems.
{
  imports = [ ./fonts.nix ./audio.nix ./hardware.nix ];
}
