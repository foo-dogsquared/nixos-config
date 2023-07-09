{ pkgs ? import <nixpkgs> { } }:

with pkgs;

let
  asciidoctorWrapper = writeShellScriptBin "asciidoctor" ''
    ${lib.getBin gems}/bin/asciidoctor -T ${./assets/templates/asciidoctor} $@
  '';

  gems = bundlerEnv {
    name = "nixos-config-project-docs";
    ruby = ruby_3_1;
    gemdir = ./.;
  };
in
mkShell {
  packages = [
    asciidoctorWrapper
    gems
    gems.wrappedRuby
    bundix

    hugo
    go
    nodePackages.prettier
    vscode-langservers-extracted
  ];
}
