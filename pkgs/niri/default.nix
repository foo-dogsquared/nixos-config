{ lib
, fetchFromGitHub
, rustPlatform
, pkg-config
, pipewire
, udev
, clang
, libclang
, libxkbcommon
, libinput
, systemd
, wayland
, mesa
, seatd
}:

rustPlatform.buildRustPackage rec {
  pname = "niri";
  version = "0.1.0-alpha.2";

  src = fetchFromGitHub {
    owner = "YaLTeR";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-eNzmQCgOUCX0RT/9ilhf1RXWorHM9SOVSP1brKevkjs=";
  };

  nativeBuildInputs = [
    pkg-config
    clang
  ];

  buildInputs = [
    libclang.lib
    libinput
    libxkbcommon
    mesa
    pipewire
    seatd
    systemd
    udev
    wayland
  ];

  env.LIBCLANG_PATH = "${libclang.lib}/lib";

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "smithay-0.3.0" = "sha256-Eqs4wqogdld6MHOXQ2NRFCgJH4RHf4mYWFdjRVUVxsk=";
    };
  };

  meta = with lib; {
    homepage = "https://github.com/YaLTeR/niri";
    description = "Scrollable tiling window manager";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ foo-dogsquared ];
    platforms = platforms.linux;
  };
}
