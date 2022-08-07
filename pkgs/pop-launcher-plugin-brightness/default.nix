{ stdenv, lib, fetchFromGitHub, brightnessctl, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "pop-launcher-plugin-brightness";
  version = "2022-08-07";
  format = "other";

  src = fetchFromGitHub {
    owner = "lucas-dclrcq";
    repo = "pop-launcher-brightness-plugin";
    rev = "d77027a7f99061f52875f60b6aae10efd3163863";
    sha256 = "sha256-5XUJx68N779MdYd1YNYi1QkBWRmgsrmXQblEciSzsiA=";
  };

  dontBuild = true;
  dontConfigure = true;

  runtimeDependencies = [ brightnessctl ];

  installPhase = ''
    install -Dm644 plugin.ron -t $out/share/pop-launcher/plugins/bright
    install -Dm755 bright -t $out/share/pop-launcher/plugins/bright
  '';

  meta = with lib; {
    homepage = "https://github.com/lucas-dclrcq/pop-launcher-brightness-plugin";
    description = "Control your screen brightness via pop-launcher";
    # It doesn't have a license so it is unfree by default.
  };
}
