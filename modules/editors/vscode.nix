# Visual Studio but for codes...
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

    # Your favorite programming language for a game of barnyard darts.
    {
      name = "dart-code";
      publisher = "Dart-Code";
      version = "3.13.2";
      sha256 = "05pyqijwkqby4q9izkddkrhlfd0jhdc1xqdf6342l1r7p8bwyqyr";
    }

    # RULES RULE, INCONSISTENCY DROOLS!
    {
      name = "EditorConfig";
      publisher = "EditorConfig";
      version = "0.15.1";
      sha256 = "18r19dn1an81l2nw1h8iwh9x3sy71d4ab0s5fvng5y7dcg32zajd";
    }

    # Flutter like a butter, sting like a b.
    {
      name = "flutter";
      publisher = "Dart-Code";
      version = "3.13.2";
      sha256 = "1jpb01a3fazwi89b2f59sm8sbzbfaawdxaais53dsay1wbg5hncz";
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
  ];
  vscode-with-extensions = pkgs.vscode-with-extensions.override {
    vscodeExtensions = extensions;
  };
in
{
  options.modules.editors.vscode = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.editors.vscode.enable {
    my.packages = [
      vscode-with-extensions
    ];
  };
}
