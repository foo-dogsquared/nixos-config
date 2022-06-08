{ stdenv, lib, rustPlatform, fetchFromGitHub, pkg-config, libinput, udev }:

rustPlatform.buildRustPackage rec {
  pname = "wzmach";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "d86leader";
    repo = "wzmach";
    rev = "v${version}";
    sha256 = "sha256-o9fCiuNTyP4vUoUm9etqdAzUnd7PmXbTm7Zhim0y4rE=";
  };

  cargoSha256 = "sha256-MknrsJuNMS5BgCbgMuqSPzxyR70y24TGsKMPOuzfkjY=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libinput udev ];

  postInstall = ''
    install -Dm644 config.ron -t $out/share/wzmach/examples
  '';

  meta = with lib; {
    homepage = "https://github.com/d86leader/wzmach";
    description = "Gesture engine for Wayland";
    license = licenses.gpl3Only;
    platform = platforms.linux;
  };
}
