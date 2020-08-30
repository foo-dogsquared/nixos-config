# All of my text editors (and IDEs) modules are to be put here.
# From Visual Studio Code, Emacs, Neovim, and whatnot.
# The entryway to all of your text editors and IDEs.
{ config, options, lib, pkgs, ... }:

with lib;
{
  imports = [
    ./emacs.nix
    ./neovim.nix
    ./vscode.nix
  ];

  options.modules.editors = {
    default = mkOption {
      type = types.str;
      default = "vim";
    };
  };

  config = {
    my.env.EDITOR = config.modules.editors.default;
  };
}
