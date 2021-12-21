{ lib, stdenv, bash, fetchFromGitHub, glib, gettext, zip, unzip }:

# TODO: Deprecate this package once it is successfully packaged in nixpkgs.
stdenv.mkDerivation rec {
  pname = "gnome-shell-extension-burn-my-windows";
  version = "2";

  src = fetchFromGitHub {
    owner = "Schneegans";
    repo = "Burn-My-Windows";
    rev = "v${version}";
    sha256 = "sha256-+8neRxlkNWdLDWAAZWK2iFfuvO0rq05orBTn18tWKf4=";
  };

  nativeBuildInputs = [ glib gettext ];
  buildInputs = [ zip ];
  skipConfigure = true;

  buildPhase = ''
    # This will create the necessary files to be exported.
    # And we'll use the generated zip file as a foundation for the output.
    make SHELL=${bash}/bin/bash ${passthru.extensionUuid}.zip
  '';

  installPhase = let
    extensionDir =
      "$out/share/gnome-shell/extensions/${passthru.extensionUuid}";
  in ''
    # Install the required extensions file.
    mkdir -p ${extensionDir}
    ${unzip}/bin/unzip ${passthru.extensionUuid}.zip -d ${extensionDir}

    # Install the GSchema.
    install -Dm644 schemas/* -t "${
      glib.makeSchemaPath "$out" "${pname}-${version}"
    }"
  '';

  passthru.extensionUuid = "burn-my-windows@schneegans.github.com";

  meta = with lib; {
    description = "A GNOME shell extension to disintegrate windows in the old-fashioned way";
    license = licenses.gpl3Plus;
    homepage = "https://github.com/Schneegans/Burn-My-Windows";
    platforms = platforms.linux;
  };
}
