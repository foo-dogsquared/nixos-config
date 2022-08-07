{ stdenv, lib, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "pop-launcher-plugin-jetbrains";
  version = "2022-08-07";

  src = fetchFromGitHub {
    owner = "oknozor";
    repo = "pop-launcher-jetbrains-plugin";
    rev = "9883ee1361c2de0bdd8ba4438a8e854303cdece6";
    sha256 = "sha256-yvkKZTulgDqr2k9M1rEEHc52IDcqMw9UA3xe/HOLD9M";
  };

  cargoSha256 = "sha256-WuqRU+dkRVGQL+fb3utcuS4HZRTGkBtcnri7lqO9rZk=";

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
