# The language for portable shell scripting.
{ config, options, lib, pkgs, ... }:

with lib;
{
  options.modules.dev.perl = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.dev.perl.enable {
    my.packages = with pkgs; [
      perl
      perlPackages.ModernPerl
      perlPackages.ModuleBuild
      perlPackages.ModuleInfo
      perlPackages.ModuleInstall
    ];
  };
}
