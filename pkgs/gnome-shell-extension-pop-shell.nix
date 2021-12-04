{ lib, stdenv, fetchFromGitHub, glib, nodePackages }:

let
  INSTALLBASE = "$out/share/gnome-shell/extensions";
in
stdenv.mkDerivation rec {
  pname = "gnome-shell-extension-pop-shell";
  version = "unstable-2021-11-30";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "shell";
    rev = "4b65ee865d01436ec75a239a0586a2fa6051b8c3";
    sha256 = "sha256-DHmp3kzBgbyxRe0TjER/CAqyUmD9LeRqAFQ9apQDzfk=";
  };

  nativeBuildInputs = [ glib nodePackages.typescript ];
  skipConfigure = true;

  # Rather than patching the installation, we can create our own easily.
  installPhase = ''
    mkdir -p ${INSTALLBASE}/${passthru.extensionUuid}
    cp -r _build/* ${INSTALLBASE}/${passthru.extensionUuid}/

    # TODO: Uncomment once custom gsettings works.
    # Unfortunately custom gsettings seems to be not properly integrated with NixOS yet.
    #
    # For more information, please track the following issue:
    # https://github.com/NixOS/nixpkgs/issues/92265
    #
    # It also contains additional links to related issues and whatnot.
    #install -Dm644 keybindings/*.xml -t $out/share/gnome-control-center/keybindings

    # Export the custom GSettings schema.
    install -Dm644 _build/schemas/* -t $out/share/glib-2.0/schemas
  '';

  passthru.extensionUuid = "pop-shell@system76.com";

  meta = with lib; {
    description = "A keyboard-driven layer for GNOME shell";
    license = licenses.gpl3;
    homepage = "https://github.com/pop-os/shell";
  };
}
