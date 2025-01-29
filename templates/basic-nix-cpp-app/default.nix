{ stdenv, lib, cmake, meson, ninja, pkg-config, boost, nix, semver-cpp }:

stdenv.mkDerivation {
  pname = "app";
  version = "0.1.0";

  src = ./.;

  nativeBuildInputs = [ meson ninja pkg-config ];

  buildInputs = [ cmake boost nix semver-cpp ];

  meta = with lib; {
    description = "Basic Nix CLI";
    license = licenses.mit;
    maintainers = with maintainers; [ foo-dogsquared ];
    platforms = nix.meta.platforms;
  };
}
