{ config, lib, options, ... }:

{
  # A compatibility option while the newer iteration of configuring nixpkgs
  # inside our internal flake-parts module is in progress.
  imports = [
    (lib.mkAliasOptionModule [ "nixpkgsBranch" ] [ "nixpkgs" "branch" ])
  ];

  options.nixpkgs = {
    branch = lib.mkOption {
      type = lib.types.nonEmptyStr;
      default = "nixpkgs";
      description = ''
        The nixpkgs branch to be used as the nixpkgs instance of the
        environment. By default, it will use the `nixpkgs` flake input.

        ::: {.note}
        This is based from your flake inputs and not somewhere else. If you
        want to have support for multiple nixpkgs branch, simply add them as
        a flake input.
        :::
      '';
      example = "nixos-unstable-small";
    };

    config = lib.mkOption {
      type = with lib.types; attrsOf anything;
      description = ''
        The configuration to be passed to the nixpkgs instance of the module
        environment.
      '';
      default = { };
      example = {
        allowUnfree = true;
      };
    };

    overlays = lib.mkOption {
      type = with lib.types; listOf (functionTo raw);
      default = [ ];
      example = lib.literalExpression ''
        [
          inputs.neovim-nightly-overlay.overlays.default
          inputs.emacs-overlay.overlays.default
        ]
      '';
      description = ''
        A list of overlays to be applied for the nixpkgs instance of the
        environment.
      '';
    };
  };
}
