{ lib, stdenv, fetchFromGitHub, glib, nodePackages }:

stdenv.mkDerivation rec {
  pname = "gnome-shell-extension-pop-shell";
  version = "unstable-2022-01-19";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "shell";
    rev = "21745c4a8076ad52c9ccc77ca5726f5c7b83de6c";
    sha256 = "sha256-d6NRNbTimwtGVLhcpdFD1AuignVii/xi3YtMWzkS/v0=";
  };

  nativeBuildInputs = [ glib nodePackages.typescript ];
  skipConfigure = true;

  makeFlags = [
    "INSTALLBASE=$(out)/share/gnome-shell/extensions"
    "PLUGIN_BASE=$(out)/lib/pop-shell/launcher"
    "SCRIPTS_BASE=$(out)/lib/pop-shell/scripts"
    "UUID=${passthru.extensionUuid}"
  ];

  postInstall = ''
     install -Dm644 $out/share/gnome-shell/extensions/${passthru.extensionUuid}/schemas/* -t "${
       glib.makeSchemaPath "$out" "${pname}-${version}"
     }"

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
    license = licenses.gpl3;
    homepage = "https://github.com/pop-os/shell";
    platforms = platforms.linux;
  };
}
