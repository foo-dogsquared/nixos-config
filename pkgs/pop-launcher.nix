{ lib, fetchFromGitHub, rustPlatform, pkg-config, openssl, gtk3 }:

let
  distributionPluginPath = "$out/lib/pop-launcher";
in
rustPlatform.buildRustPackage rec {
  pname = "pop-launcher";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "launcher";
    rev = version;
    sha256 = "sha256-I713Er96ONt7L0LLzemNtc/qpy+RBaAuNF7SU+FG8LA=";
  };

  cargoBuildFlags = [ "-p" "pop-launcher-bin" ];
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl gtk3 ];

  # Replace the distribution plugins path since it is only usable with traditional Linux distros.
  prePatchPhase = ''
    substituteInPlace src/lib.rs --replace "/usr/lib/pop-launcher" "${distributionPluginPath}"
    substituteInPlace plugins/src/scripts/mod.rs --replace "/usr/lib/pop-launcher/scripts" "${distributionPluginPath}/scripts"
  '';

  # Installing and configuring the built-in plugins.
  postInstall = ''
    # Clean up the name.
    mv $out/bin/pop-launcher{-bin,}

    # Configure the built-in plugins properly.
    for plugin in plugins/src/*; do
      plugin_name=$(basename "$plugin")
      plugin_path="${distributionPluginPath}/plugins/$plugin_name"

      # We are only after the plugins which are stored inside subdirectories.
      [ -d $plugin ] || continue

      # Configure each built-in plugin with the plugin metadata file and the binary (which is also `pop-launcher`).
      mkdir -p "$plugin_path" && cp "$plugin/plugin.ron" "$plugin_path"
      ln -sf "$out/bin/pop-launcher" "$plugin_path/$plugin_name"
    done
  '';

  cargoSha256 = "sha256-swkQAja+t/yz5TFq5omskP7e/OVaHK7/a6TFuP+T/VY=";
  meta = with lib; {
    description = "Modular IPC-based desktop launcher service";
    homepage = "https://github.com/pop-os/launcher";
    license = licenses.gpl3;
  };
}
