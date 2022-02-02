{ stdenv, lib, fetchgit, meson, ninja, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "blueprint-compiler";
  version = "2022-02-02";

  src = fetchgit {
    url = "https://gitlab.gnome.org/jwestman/blueprint-compiler.git";
    rev = "bac008296a10b4407ec0a385689f8e11e813d1b7";
    sha256 = "sha256-EWUAoWZbakOW6cSAKnYiXpTtvW9qRhmPK9bGdGr4JKI=";
  };

  format = "other";
  nativeBuildInputs = [ meson ninja ];

  meta = with lib; {
    description = "Compiles Blueprint to GTK XML";
    homepage = "https://gitlab.gnome.org/jwestman/blueprint-compiler";
    license = licenses.gpl3;
  };
}
