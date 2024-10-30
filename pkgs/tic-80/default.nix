# Build the TIC-80 virtual computer console with the PRO version. The
# developers are kind enough to make it easy to compile it if you know
# how.
{ stdenv
, lib
, SDL2
, SDL2_sound
, alsa-lib
, cmake
, fetchFromGitHub
, freeglut
, git
, gtk3
, dbus
, libGLU
, libX11
, libglvnd
, libsamplerate
, mesa
, pkg-config
, sndio
, zlib

, pulseaudioSupport ? stdenv.isLinux
, libpulseaudio

, waylandSupport ? true
, wayland
, libxkbcommon
, libdecor

, esoundSupport ? true
, espeak

, jackSupport ? true
, jack2

  # Ruby support requires compiling mruby so we'll skip it for now.
, rubySupport ? false
, ruby
, rake

, pythonSupport ? true
, python3

, withPro ? true
}:

# TODO: Fix the timestamp in the help section.
stdenv.mkDerivation rec {
  pname = "tic-80";
  version = "unstable-2023-07-18";

  src = fetchFromGitHub {
    owner = "nesbox";
    repo = "TIC-80";
    rev = "68b94ee596e1ac218b8b9685fd0485c7ee8d2f18";
    hash = "sha256-S3LYuRRFMZYl6dENrV21bowzo7smm+zSHXt77/83oL0=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [
    alsa-lib
    freeglut
    gtk3
    libsamplerate
    libGLU
    libglvnd
    mesa
    git
    SDL2
    SDL2_sound
    zlib
    sndio
  ]
  ++ lib.optional pulseaudioSupport libpulseaudio
  ++ lib.optional jackSupport jack2
  ++ lib.optional esoundSupport espeak
  ++ lib.optionals rubySupport [
    ruby
    rake
  ]
  ++ lib.optional pythonSupport python3
  ++ lib.optionals (stdenv.isLinux && waylandSupport) [
    wayland
    libxkbcommon
    libdecor
  ];

  cmakeFlags = lib.optional withPro "-DBUILD_PRO=ON";

  # Export all of the TIC-80-related utilities.
  outputs = [ "out" "dev" ];
  postInstall = ''
    install -Dm755 bin/* -t $dev/bin
    install -Dm644 lib/* -t $dev/lib
    install -Dm644 ../include/* -t $dev/include

    mkdir -p $out/share/tic80
    cp -r ../demos $out/share/tic80/
  '';

  meta = with lib; {
    description = "A fantasy computer with built-in game dev tools.";
    homepage = "https://tic80.com/";
    license = licenses.mit;
  };
}
