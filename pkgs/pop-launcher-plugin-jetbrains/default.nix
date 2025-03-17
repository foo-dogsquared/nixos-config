{ stdenv, lib, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "pop-launcher-plugin-jetbrains";
  version = "2024-04-04";

  src = fetchFromGitHub {
    owner = "oknozor";
    repo = "pop-launcher-jetbrains-plugin";
    rev = "18a3d3d32c5760ad2086380a47f684c7b12b5d68";
    hash = "sha256-lBv1jwekbod3H1ANzAEKAHDNHdRb3LD2PM1LXiLErv8=";
  };

  cargoHash = "sha256-d54PlaKZaDhQ6PI/J1+IOMqgC/h5XUuEkULLbSTIcUw=";
  useFetchCargoVendor = true;

  postInstall = ''
    install -Dm644 plugin.ron -t "$out/share/pop-launcher/plugins/jetbrains"
    mv "$out/bin/pop-launcher-jetbrains-plugin" "$out/share/pop-launcher/plugins/jetbrains/jetbrains"
    rmdir $out/bin
  '';

  meta = with lib; {
    homepage = "https://github.com/oknozor/pop-launcher-jetbrains-plugin";
    description = "Launch your JetBrains IDE with Pop launcher";
    license = licenses.mit;
  };
}
