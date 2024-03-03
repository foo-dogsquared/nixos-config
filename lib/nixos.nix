# All of the functions suitable only for NixOS.
{ pkgs, lib, self }:

{
  # Checks if the NixOS configuration is part of the nixos-generator build.
  # Typically, we just check if there's a certain attribute that is imported
  # from it.
  hasNixosFormat = config:
    lib.hasAttrByPath [ "formatAttr" ] config;

  # Checks if the NixOS config is being built for a particular format.
  isFormat = config: format:
    (config.formatAttr or "") == format;
}
