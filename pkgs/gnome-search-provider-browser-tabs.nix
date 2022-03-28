{ stdenv, lib, fetchFromGitHub, rustPlatform, mkYarnPackage, meson, ninja, yarn
, zip }:

let
  version = "0.1.1";

  repo = fetchFromGitHub {
    owner = "harshadgavali";
    repo = "searchprovider-for-browser-tabs";
    rev = "connector-v${version}";
    sha256 = "sha256-5b48BZOQOSxNuFe7ehtLM5K1Qx/EUXzGeogj2vhT3bs=";
  };

  meta = with lib; {
    homepage =
      "https://github.com/harshadgavali/searchprovider-for-browser-tabs";
    license = licenses.mit;
    platforms = platforms.unix;
  };
in lib.recurseIntoAttrs {
  gnome-shell-extension = mkYarnPackage rec {
    inherit meta;
    pname = "gnome-search-provider-browser-tabs";

    # This is more inline with the metadata from the shell extension itself.
    version = "4";

    src = "${repo}/shellextension";

    buildPhase = ''
      yarn --offline run build
    '';

    installPhase = ''
      install -Dm644 deps/shellextension/dist/extension.js -t "$out/share/gnome-shell/extensions/${passthru.extensionUuid}"
      install -Dm644 deps/shellextension/dist/metadata.json -t "$out/share/gnome-shell/extensions/${passthru.extensionUuid}"
    '';

    # We're overriding the 'distPhase' from mkYarnPackage.
    distPhase = "true";

    passthru.extensionUuid = "browser-tabs@com.github.harshadgavali";
  };

  web-extension = let
    folder = "webextension";
    chromiumAddonId = "pjidkdbbdemngigldodbdpkpggmgilnl";
  in mkYarnPackage rec {
    inherit version meta;
    pname = "firefox-extension-tab-search-provider-for-gnome";

    src = "${repo}/${folder}";

    buildPhase = ''
      yarn --offline run build
    '';

    installPhase = ''
      # Packaging Chromium addon.
      install -Dm644 deps/${folder}/dist/chromium/* -t "$out/share/chromium/extensions/${chromiumAddonId}/${version}_0"

      # Package Mozilla Firefox extension.
      ${zip}/bin/zip --recurse-paths --junk-paths nixos@${pname}.xpi deps/${folder}/dist/firefox/
      install -Dm644 nixos@${pname}.xpi -t $out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}
    '';

    # Overriding the distPhase from mkYarnPackage.
    distPhase = "true";
  };

  connector = stdenv.mkDerivation rec {
    inherit version meta;
    pname = "tab-search-connector-provider";
    nativeBuildInputs = [
      meson
      ninja
      rustPlatform.cargoSetupHook
      rustPlatform.rust.rustc
      rustPlatform.rust.cargo
    ];

    src = "${repo}/connector";
    cargoDeps = rustPlatform.fetchCargoTarball {
      inherit src;
      name = "${pname}-${version}";
      sha256 = "sha256-SULUONFmsnEiWoAWpGOLynSXF032qW+QcYfzxQrAFLQ=";
    };

    mesonFlags = [ "-Drelease-bindir=${placeholder "out"}/bin" ];
  };
}
