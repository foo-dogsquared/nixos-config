{ lib, fetchFromGitHub, rustPlatform, just, runtimeShell }:

rustPlatform.buildRustPackage rec {
  pname = "pop-launcher";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "launcher";
    rev = version;
    sha256 = "sha256-BQAO9IodZxGgV8iBmUaOF0yDbAMVDFslKCqlh3pBnb0=";
  };

  cargoSha256 = "sha256-cTvrq0fH057UIx/O9u8zHMsg+psMGg1q9klV5OMxtok=";

  # Replace the distribution plugins path since it is only usable with traditional Linux distros.
  postPatch = ''
    substituteInPlace justfile --replace "#!/usr/bin/env sh" "#!${runtimeShell}"
    substituteInPlace src/lib.rs --replace "/usr/lib/pop-launcher" "$out/share/pop-launcher"
    substituteInPlace plugins/src/scripts/mod.rs --replace "/usr/lib/pop-launcher" "$out/share/pop-launcher"
  '';

  nativeBuildInputs = [ just ];
  buildPhase = "just";
  installPhase = "just base_dir=$out/ install";

  meta = with lib; {
    description = "Modular IPC-based desktop launcher service";
    homepage = "https://github.com/pop-os/launcher";
    license = licenses.mpl20;
  };
}
