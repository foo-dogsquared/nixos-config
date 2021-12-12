{ lib, stdenv, bash, fetchFromGitHub, glib, gettext, zip, unzip }:

# TODO: Deprecate this package once it is successfully packaged in nixpkgs.
# This is done automatically from the following PR:
# https://github.com/NixOS/nixpkgs/pull/118232
#
# It is yet to be fixed as of the latest commit at the time of this writing (i.e., e09a539ccbb).
# Please refer to the `pkgs/desktops/gnome/extensions/{extensions.json,extensionRenames.nix}` in the future to check.
stdenv.mkDerivation rec {
  pname = "gnome-shell-extension-fly-pie";
  version = "12";

  src = fetchFromGitHub {
    owner = "Schneegans";
    repo = "Fly-Pie";
    rev = "v${version}";
    sha256 = "sha256-z56emJCnf9hXtY9C5czXRRXzzBgoK7683sH+D70v7J4=";
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

  passthru.extensionUuid = "flypie@schneegans.github.com";

  meta = with lib; {
    description = "A marking menu for GNOME shell";
    license = licenses.mit;
    homepage = "https://github.com/Schneegans/Fly-Pie";
    platforms = platforms.linux;
  };
}
