# Visual Studio but for codes...
# The code is really stolen from the NixOS wiki at https://nixos.wiki/wiki/Vscode.
{ config, options, lib, pkgs, ... }:

with lib;
let
  extensions = (with pkgs.vscode-extensions; [
    bbenoist.Nix
    ms-python.python
    ms-azuretools.vscode-docker
    ms-vscode-remote.remote-ssh
  ]) ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    # Edit muh readable text documents that can convert into multiple formats.
    {
      name = "asciidoctor-vscode";
      publisher = "asciidoctor";
      version = "2.8.3";
      sha256 = "1jh28qqa0qcycmj3h69dxg49l6zka5yb1vsdqyzc9cqnf8m6ps2a";
    }

    # Make VS Code more practical with style!
    {
      name = "bracket-pair-colorizer-2";
      publisher = "CoenraadS";
      version = "0.2.0";
      sha256 = "0nppgfbmw0d089rka9cqs3sbd5260dhhiipmjfga3nar9vp87slh";
    }

    # Your favorite programming language for a game of barnyard darts.
    {
      name = "dart-code";
      publisher = "Dart-Code";
      version = "3.13.2";
      sha256 = "05pyqijwkqby4q9izkddkrhlfd0jhdc1xqdf6342l1r7p8bwyqyr";
    }

    {
      name = "vscode-eslint";
      publisher = "dbaeumer";
      version = "2.1.8";
      sha256 = "18yw1c2yylwbvg5cfqfw8h1r2nk9vlixh0im2px8lr7lw0airl28";
    }

    # RULES RULE, INCONSISTENCY DROOLS!
    {
      name = "EditorConfig";
      publisher = "EditorConfig";
      version = "0.15.1";
      sha256 = "18r19dn1an81l2nw1h8iwh9x3sy71d4ab0s5fvng5y7dcg32zajd";
    }

    # Flutter like a butter, dart like a bee.
    {
      name = "flutter";
      publisher = "Dart-Code";
      version = "3.13.2";
      sha256 = "1jpb01a3fazwi89b2f59sm8sbzbfaawdxaais53dsay1wbg5hncz";
    }

    # Git those lens with a magnifying glass, son.
    {
      name = "gitlens";
      publisher = "eamodio";
      version = "10.2.2";
      sha256 = "00fp6pz9jqcr6j6zwr2wpvqazh1ssa48jnk1282gnj5k560vh8mb";
    }

    # Muh consistent theming.
    {
      name = "nord-visual-studio-code";
      publisher = "arcticicestudio";
      version = "0.14.0";
      sha256 = "0ni924bm62awk9p39cf297kximy6xldhjjjycswx4qg2w89b505x";
    }

    # Will that make me pretty?
    {
      name = "prettier-vscode";
      publisher = "esbenp";
      version = "5.5.0";
      sha256 = "0hw68s85w3aqaslzfcbsfskng8i0bvfnmbwk11ldrpdmafk693nc";
    }

    # Edit the remote daemon in you.
    {
      name = "remote-ssh-edit";
      publisher = "ms-vscode-remote";
      version = "0.47.2";
      sha256 = "1hp6gjh4xp2m1xlm1jsdzxw9d8frkiidhph6nvl24d0h8z34w49g";
    }

    # Muh consistent icons.
    {
      name = "material-icon-theme";
      publisher = "PKief";
      version = "4.2.0";
      sha256 = "1in8lj5gim3jdy33harib9z8qayp5jn8pz6j0zpicbzxx87g2hm1";
    }

    # Creating a Rust mini-IDE.
    {
      name = "rust";
      publisher = "rust-lang";
      version = "0.7.8";
      sha256 = "039ns854v1k4jb9xqknrjkj8lf62nfcpfn0716ancmjc4f0xlzb3";
    }
  ];
in {
  options.modules.editors.vscode = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.editors.vscode.enable {
    my.home = {
      programs.vscode = {
        enable = true;
        extensions = extensions;
        userSettings = {
          "diffEditor.codeLens" = true;
          "editor.fontFamily" =
            "'Iosevka', 'Droid Sans Mono', 'monospace', monospace, 'Droid Sans Fallback'";
          "editor.fontLigatures" = true;
          "eslint.alwaysShowStatus" = true;
          "git.alwaysShowStagedChangesResourceGroup" = true;
          "update.mode" = "none";
          "workbench.colorTheme" = "Nord";
          "workbench.iconTheme" = "material-icon-theme";
        };
      };
    };
  };
}
