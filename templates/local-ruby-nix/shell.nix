{ pkgs ? import <nixpkgs> { }, ruby-nix }:

with pkgs;

let
  gems = ruby-nix.lib pkgs {
    name = "ruby-nix-env";
    ruby = ruby_3_1;
    gemset = ./gemset.nix;
  };
in
mkShell {
  buildInputs = [
    gems.env
    gems.ruby
  ];

  packages = [
    # Formatters
    nixpkgs-fmt

    # Language servers
    rnix-lsp
  ];
}
