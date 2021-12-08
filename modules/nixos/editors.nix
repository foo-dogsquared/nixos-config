# Your text editor war arsenal.
{ config, options, lib, pkgs, ... }:

let cfg = config.modules.editors;
in {
  options.modules.editors = {
    neovim.enable = lib.mkEnableOption "Enable Neovim and its components";
    vscode.enable = lib.mkEnableOption "Enable Visual Studio Code";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.neovim.enable {
      programs.neovim = {
        enable = true;
        defaultEditor = true;
        withNodeJs = true;
        withRuby = true;
      };

      environment.systemPackages = with pkgs; [ editorconfig-core-c ];
    })

    (lib.mkIf cfg.vscode.enable {
      environment.systemPackages = with pkgs; [ vscode editorconfig-core-c ];
    })
  ];
}
