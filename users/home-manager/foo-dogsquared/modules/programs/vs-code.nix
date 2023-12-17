{ config, lib, pkgs, ... }:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.programs.vs-code;
in
{
  options.users.foo-dogsquared.programs.vs-code.enable =
    lib.mkEnableOption "foo-dogsquared's Visual Studio Code setup";

  config = lib.mkIf cfg.enable {
    programs.vscode = {
      extensions = with pkgs; [
        # Additional language support.
        bbenoist.nix
        graphql.vscode-graphql
        ms-vscode.cmake-tools
        ms-vscode.cpptools
        ms-vscode.powershell

        # Extra editor niceties.
        eamodio.gitlens
        mkhl.direnv
        usernamehw.errorlens
        vadimcn.vscode-lldb

        # The other niceties.
        editorconfig.editorconfig
      ];

      settings = {
        "extensions.ignoreRecommendations" = true;
      };
    };
  };
}
