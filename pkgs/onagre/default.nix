{ stdenv, lib, rustPlatform, fetchFromGitHub, cmake, pkg-config, freetype, expat, wayland, libX11 }:

rustPlatform.buildRustPackage rec {
  pname = "onagre";
  version = "1.0.0-alpha.0";

  src = fetchFromGitHub {
    owner = "oknozor";
    repo = "onagre";
    rev = version;
    sha256 = "sha256-hP+slfCWgsTgR2ZUjAmqx9f7+DBu3MpSLvaiZhqNK1Q=";
  };

  cargoSha256 = "sha256-IOhAGrAiT2mnScNP7k7XK9CETUr6BjGdQVdEUvTYQT4=";

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    freetype
    expat
  ];

  propagatedBuildInputs = [
    wayland
    libX11
  ];

  meta = with lib; {
    homepage = "https://github.com/oknozor/onagre";
    description = "General application launcher for X/Wayland";
    license = licenses.mit;
  };
}
