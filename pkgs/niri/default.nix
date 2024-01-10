{ lib
, fetchFromGitHub
, rustPlatform
, pkg-config
, pipewire
, udev
, libxkbcommon
, libinput
, libglvnd
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
  version = "0.1.0-alpha.3";

  src = fetchFromGitHub {
    owner = "YaLTeR";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-X3n8Mt3M5+Z8YDvYZOVCgKSHLTQJtBdbMBl0c5O/tt0=";
  };

  nativeBuildInputs = [
    makeBinaryWrapper
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    libinput
    libxkbcommon
    libglvnd
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
      "smithay-0.3.0" = "sha256-+VIKgdonZScAb38QcSatyoYGPSV3Q7lscd3U5jajdbM=";
    };
  };

  RUSTFLAGS = builtins.map (arg: "-C link-arg=${arg}") [
    "-Wl,--push-state,--no-as-needed"
    "-lEGL"
    "-lwayland-client"
    "-Wl,--pop-state"
  ];

  postPatch = ''
    patchShebangs ./resources/niri-session
    substituteInPlace ./resources/niri.service \
      --replace '/usr/bin' "$out/bin"
  '';

  postInstall = ''
    install -Dm0755 resources/niri-session -t $out/bin

    # This session script is used as a system component so we may as well fully
    # wrap this with nixpkgs' dependencies.
    wrapProgram $out/bin/niri-session \
      --prefix PATH ':' '${lib.makeBinPath [ coreutils systemd dbus ]}'

    install -Dm0644 resources/niri.desktop -t $out/share/wayland-sessions
    install -Dm0644 resources/niri-portals.conf -t $out/share/xdg-desktop-portal
    install -Dm0644 resources/niri{-shutdown.target,.service} -t $out/lib/systemd/user
  '';

  passthru.providedSessions = [ "niri" ];

  meta = with lib; {
    homepage = "https://github.com/YaLTeR/niri";
    description = "Scrollable tiling window manager";
    license = licenses.gpl3Plus;
    mainProgram = "niri";
    maintainers = with maintainers; [ foo-dogsquared ];
    platforms = platforms.linux;
  };
}
