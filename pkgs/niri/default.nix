{ lib
, fetchFromGitHub
, rustPlatform
, pkg-config
, pipewire
, udev
, libxkbcommon
, libinput
, systemd
, wayland
, mesa
, seatd

# Session script dependencies.
, makeBinaryWrapper
, coreutils
, dbus
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
    makeBinaryWrapper
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    libinput
    libxkbcommon
    mesa
    pipewire
    seatd
    systemd
    udev
    wayland
  ];

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = {
      "smithay-0.3.0" = "sha256-Eqs4wqogdld6MHOXQ2NRFCgJH4RHf4mYWFdjRVUVxsk=";
    };
  };

  postPatch = ''
    patchShebangs ./resources/niri-session
  '';

  postInstall = ''
    install -Dm0755 resources/niri-session -t $out/libexec
    makeWrapper $out/libexec/niri-session \
      --prefix PATH ':' '${lib.makeBinPath [ coreutils systemd dbus ]}'

    install -Dm0644 resources/niri.desktop -t $out/share/applications
    install -Dm0644 resources/niri-portals.conf -t $out/share/xdg-desktop-portal
    install -Dm0644 resources/niri{-shutdown.target,.service} -t $out/share/systemd
  '';

  meta = with lib; {
    homepage = "https://github.com/YaLTeR/niri";
    description = "Scrollable tiling window manager";
    license = licenses.gpl3Plus;
    mainProgram = "niri";
    maintainers = with maintainers; [ foo-dogsquared ];
    platforms = platforms.linux;
  };
}
