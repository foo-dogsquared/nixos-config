# My usual toolchain for developing Hugo projects.
{ mkShell
, callPackage
, hugo
, asciidoctor
, pandoc
, git
, go
, nodejs_latest
, imagemagick
}:

let
  nodejsDevshell = callPackage ./nodejs.nix { };
  goDevshell = callPackage ./go.nix { };
in
mkShell {
  packages = [
    asciidoctor # Some sites use this.
    pandoc # Also these.
    hugo # The main tool.
    go # I might use Go modules which requires the Golang runtime.
    git # VCS of my choice.
    nodejs_latest # The supported NodeJS version.
    imagemagick # Everyman's image processing framework.
  ];

  inputsFrom = [
    nodejsDevshell
    goDevshell
  ];
}
