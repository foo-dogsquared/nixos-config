# The language for portable shell scripting.
{ config, options, lib, pkgs, ... }:

with lib;
let
  perlWithPackages = pkgs.perl.withPackages (p: with pkgs.perlPackages;
  [
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
  };

  config = mkIf config.modules.dev.perl.enable {
    my.packages = [ perlWithPackages ];
  };
}
