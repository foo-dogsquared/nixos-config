{ stdenv, lib, fetchgit, meson, ninja, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "blueprint-compiler";
  version = "2022-02-23";

  src = fetchgit {
    url = "https://gitlab.gnome.org/jwestman/blueprint-compiler.git";
    rev = "4b42016837a6b5bd63f99647423602426168450e";
    sha256 = "sha256-141+LHZQm3S9GxRrineTHb7UsNBtszGeMTakoRv3CFs=";
  };

  format = "other";
  nativeBuildInputs = [ meson ninja ];

  meta = with lib; {
    description = "Compiles Blueprint to GTK XML";
    homepage = "https://gitlab.gnome.org/jwestman/blueprint-compiler";
    license = licenses.gpl3;
  };
}
