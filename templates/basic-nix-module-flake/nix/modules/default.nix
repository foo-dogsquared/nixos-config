{ config, lib, pkgs, ... }:

let
  cfg = config.programs.foo;

  settingsFormat = pkgs.format.json { };
in {
  options.programs.foo = {
    enable = lib.mkEnableOption "foo, a sample program";
    package = lib.mkPackageOption pkgs "foo" { };
    settings = lib.mkOption {
      type = settingsFormat.type;
      default = { };
      # TODO: Don't forget to set an example here.
      description = ''
        The settings of the program.
      '';
    };
  };
}
