# A bunch of data-related tools and libraries.
{ config, options, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.dev.data;
in {
  options.modules.dev.data = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };

    dhall.enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    my.packages = with pkgs; [
      cfitsio # A data library for FITS images which is an image used for analyzing your fitness level.
      hdf5 # A binary data format with hierarchy and metadata.
      #hdfview       # HDF4 and HDF5 viewer.
      jq # A JSON parser on the command-line (with the horrible syntax, in my opinion).
      pup # A cute little puppy that can understand HTML.
      sqlite # A cute little battle-tested library for your data abominations.
      sqlitebrowser # Skim the DB and create a quick scraping script for it.
    ] ++

    (if cfg.dhall.enable then [
      dhall # A dull programmable configuration Turing-incomplete language for your guaranteed termination, neat.
      dhall-nix
      dhall-bash
      dhall-json
      dhall-text
      dhall-lsp-server
    ] else []);
  };
}
