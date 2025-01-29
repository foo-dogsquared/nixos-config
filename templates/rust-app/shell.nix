{ pkgs }:

let app = pkgs.callPackage ./. { };
in pkgs.mkShell {
  inputsFrom = [ app ];

  packages = with pkgs; [ treefmt rust-analyzer ];
}
