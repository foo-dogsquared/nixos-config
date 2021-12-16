# My usual toolchain for developing Hugo projects.
{ mkShell, hugo, git, go, nodejs-16_x }:

mkShell {
  packages = [
    hugo # The main tool.
    go # I might use Go modules which requires the Golang runtime.
    git # VCS of my choice.
    nodejs-16_x # The supported NodeJS version.
  ];
}
