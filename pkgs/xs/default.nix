{ stdenv
, lib
, fetchFromGitHub
, boost
, boehmgc
, bison
, meson
, ninja
, pkg-config
, libffi
, readline
, git
}:

stdenv.mkDerivation rec {
  pname = "xs";
  version = "unstable-2022-10-05";

  src = fetchFromGitHub {
    owner = "TieDyedDevil";
    repo = "XS";
    rev = "789540c5f208b8e8f07fc81c3bec3d0ee47c6dea";
    sha256 = "sha256-Yx6zWLZlnlckZyTljgTVCjCPtNfUbM+o4RfuOPpn8ZQ=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    boost
    bison
    boehmgc
    libffi
    readline
    git
  ];

  patches = [ ./update-build.patch ];
  postPatch = ''
    patchShebangs ./generators/*.sh
  '';

  meta = with lib; {
    homepage = "https://github.com/TieDyedDevil/XS";
    description = "Extensible shell with functional semantics and conventional syntax";

    # See doc/ANCENSTORS and doc/COPYING files for more details.
    license = licenses.publicDomain;
  };
}
