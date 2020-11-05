# The language for portable shell scripting.
{ config, options, lib, pkgs, ... }:

with lib;
let
  cfg = config.modules.dev.perl;
  perlWithPackages = pkgs.perl.withPackages (p:
    with pkgs.perlPackages; [
      ModuleBuild
      ModuleInfo
      ModuleInstall
      ModernPerl
    ]);
in {
  options.modules.dev.perl = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };

    raku.enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    my.packages = [ perlWithPackages ]
    ++ (if cfg.raku.enable then [
      rakudo
    ] else []); };
}
