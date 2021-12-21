{ lib, stdenv, bash, fetchFromGitHub, glib, gettext, zip, unzip }:

# TODO: Deprecate this package once it is successfully packaged in nixpkgs.
stdenv.mkDerivation rec {
  pname = "gnome-shell-extension-desktop-cube";
  version = "5";

  src = fetchFromGitHub {
    owner = "Schneegans";
    repo = "Desktop-Cube";
    rev = "v${version}";
    sha256 = "sha256-Z0fjOuy7WnY2JCrG8s6AsvXGrx0tDsbEmHRrtqeR9Rk=";
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

  passthru.extensionUuid = "desktop-cube@schneegans.github.com";

  meta = with lib; {
    description = "A GNOME shell to transition between workspaces the old-fashioned way";
    license = licenses.gpl3Plus;
    homepage = "https://github.com/Schneegans/Desktop-Cube";
    platforms = platforms.linux;
  };
}
