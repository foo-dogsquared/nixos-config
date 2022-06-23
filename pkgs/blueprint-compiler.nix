{ stdenv, lib, fetchgit, meson, ninja, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "blueprint-compiler";
  version = "0.2.0";

  src = fetchgit {
    url = "https://gitlab.gnome.org/jwestman/blueprint-compiler.git";
    rev = "v${version}";
    sha256 = "sha256-LXZ6n1oCbPa0taVbUZf52mGECrzXIcF8EaMVJ30rMtc=";
  };

  format = "other";
  nativeBuildInputs = [ meson ninja ];

  meta = with lib; {
    description = "Compiles Blueprint to GTK XML";
    homepage = "https://gitlab.gnome.org/jwestman/blueprint-compiler";
    license = licenses.lgpl3Only;
  };
}
