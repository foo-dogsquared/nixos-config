{ lib, fetchFromGitHub, rustPlatform, cacert, curl }:

rustPlatform.buildRustPackage rec {
  pname = "pop-launcher-plugin-duckduckgo-bangs";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "foo-dogsquared";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-RddxnoFKe7Ht+LICMdNi2GeOp95n1hSTIfc3/q+pyyo=";
  };

  runtimeDependencies = [ curl cacert ];

  # Configuring the plugin.
  postInstall = ''
    mkdir -p $out/etc/pop-launcher/plugins/bangs
    mv $out/bin/* $out/etc/pop-launcher/plugins/bangs
    cp src/plugin.ron $out/etc/pop-launcher/plugins/bangs
  '';

  cargoSha256 = "sha256-qzlZ0dbdfZwEBuQXIUndVFye6RdX8aI39D/UCagMfZg=";
  meta = with lib; {
    description = "Pop launcher for searching with Duckduckgo bangs";
    homepage = "https://github.com/foo-dogsquared/pop-launcher-plugin-duckduckgo-bangs";
    license = licenses.gpl3;
  };
}
