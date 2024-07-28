let
  sources = import ../../npins;
in
{ pkgs ? import sources.nixos-unstable { } }:

let
  docs = import ../. { inherit pkgs; };
in
pkgs.mkShell {
  inputsFrom = [ docs.website ];

  packages = with pkgs; [
    nodePackages.prettier
    vscode-langservers-extracted
  ];

  shellHook = ''
    install -Dm0644 ${docs.wmOptionsDoc.optionsAsciiDoc} ./content/en/wrapper-manager-env-options.adoc
    install -Dm0644 ${docs.wmNixosDoc.optionsAsciiDoc} ./content/en/wrapper-manager-nixos-module.adoc
    install -Dm0644 ${docs.wmHmDoc.optionsAsciiDoc} ./content/en/wrapper-manager-home-manager-module.adoc
  '';
}
