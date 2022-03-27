{ stdenv, lib, fetchgit, meson, ninja, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "blueprint-compiler";
  version = "2022-03-27";

  src = fetchgit {
    url = "https://gitlab.gnome.org/jwestman/blueprint-compiler.git";
    rev = "e3a37893a8709aa3d6a571ecb5a3f690da0ef82d";
    sha256 = "sha256-P9Ixbtdz4vcyz7Mpz3QVbXX0+Uy/HsNq8SSe7Fnp5ko=";
  };

  format = "other";
  nativeBuildInputs = [ meson ninja ];

  meta = with lib; {
    description = "Compiles Blueprint to GTK XML";
    homepage = "https://gitlab.gnome.org/jwestman/blueprint-compiler";
    license = licenses.lgpl3Only;
  };
}
