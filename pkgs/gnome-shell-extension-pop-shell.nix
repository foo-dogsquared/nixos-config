{ lib, stdenv, fetchFromGitHub, glib, nodePackages, gjs }:

stdenv.mkDerivation rec {
  pname = "gnome-shell-extension-pop-shell";
  version = "unstable-2022-09-19";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "shell";
    rev = "f0e9232164132396de5cbca60dd2cba0bea2916f";
    sha256 = "sha256-Jgcxb7FDCyoBZPCKs0wpLV/qPFn0Jp+ER0SP8SK+s7g=";
  };

  nativeBuildInputs = [ glib nodePackages.typescript gjs ];

  makeFlags = [
    "XDG_DATA_HOME=$(out)/share"
    "UUID=${passthru.extensionUuid}"
  ];

  preFixup = ''
    shellExtension="$out/share/gnome-shell/extensions/${passthru.extensionUuid}"
    chmod +x $shellExtension/*/main.js

    for file in $shellExtension/*/main.js; do
      substituteInPlace "$file" --replace "#!/usr/bin/gjs" "#!${gjs}/bin/gjs"
    done
  '';

  postInstall = ''
    # TODO: Uncomment once custom gsettings works.
    # Unfortunately custom gsettings seems to be not properly integrated with NixOS yet.
    #
    # For more information, please track the following issue:
    # https://github.com/NixOS/nixpkgs/issues/92265
    #
    # It also contains additional links to related issues and whatnot.
    #install -Dm644 keybindings/*.xml -t $out/share/gnome-control-center/keybindings
  '';

  passthru.extensionUuid = "pop-shell@system76.com";

  meta = with lib; {
    description = "A keyboard-driven layer for GNOME shell";
    license = licenses.gpl3Only;
    homepage = "https://github.com/pop-os/shell";
    platforms = platforms.linux;
  };
}
