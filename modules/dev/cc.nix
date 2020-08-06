# My stuff for C and C++.
{ config, options, lib, pkgs, ... }:

with lib;
{
  options.modules.dev.cc = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.dev.cc.enable {
    home.packages = with pkgs; [
      cmake     # Yo dawg, I heard you like Make.
      # clang     # A C compiler frontend for LLVM.
      gcc       # A compiler toolchain.
      gdb       # GNU Debugger.
      llvmPackages.libcxx      # When GCC has become too bloated for someone's taste.
    ];
  };
}
