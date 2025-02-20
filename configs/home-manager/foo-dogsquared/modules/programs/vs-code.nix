{ config, lib, pkgs, ... }:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.programs.vs-code;
in {
  options.users.foo-dogsquared.programs.vs-code.enable =
    lib.mkEnableOption "foo-dogsquared's Visual Studio Code setup";

  config = lib.mkIf cfg.enable {
    suites.editors.vscode.enable = true;
    programs.vscode = {
      extensions = with pkgs.vscode-extensions;
        [
          # Additional language support.
          bbenoist.nix
          graphql.vscode-graphql
          ms-python.python
          ms-azuretools.vscode-docker
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
          alefragnani.project-manager
          fill-labs.dependi
        ] ++ lib.optionals userCfg.programs.browsers.firefox.enable
        [ firefox-devtools.vscode-firefox-debug ]
        ++ lib.optionals config.programs.python.enable
        [ ms-toolsai.jupyter ms-toolsai.jupyter-renderers ];

      userSettings = { "extensions.ignoreRecommendations" = true; };
    };

    # We're using Visual Studio Code as a git difftool and mergetool which is
    # surprisingly good compared to the competition (which is not much).
    programs.git.extraConfig = {
      diff.tool = lib.mkDefault "vscode";
      difftool.vscode.cmd = "code --wait --diff $LOCAL $REMOTE";

      # It has a three-way merge.
      merge.tool = lib.mkDefault "vscode";
      mergetool.vscode.cmd = "code --wait --merge $REMOTE $LOCAL $BASE $MERGED";
    };
  };
}
