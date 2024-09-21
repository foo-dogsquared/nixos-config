{
  lib,
  buildHugoSite,
  bundlerEnv,
  ruby_3_1,
  writeShellScriptBin,
}:

let
  gems = bundlerEnv {
    name = "foodogsquared-docs-gemset";
    ruby = ruby_3_1;
    gemdir = ./.;
  };

  asciidoctorWrapper = writeShellScriptBin "asciidoctor" ''
    ${lib.getExe' gems "asciidoctor"} -T ${./assets/templates/asciidoctor} $@
  '';
in
buildHugoSite {
  pname = "foodogsquared-docs";
  version = "2024-09-03";

  src = lib.cleanSource ./.;

  vendorHash = "";

  buildInputs = [ asciidoctorWrapper gems ];

  meta = with lib; {
    description = "foodogsquared's NixOS configuration docs";
    license = licenses.mit;
  };
}
