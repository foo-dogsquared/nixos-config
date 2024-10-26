{ dockerTools, buildEnv, rustc, cargo, rust-bindgen, rust-analyzer, nodejs, bash
, meson, ninja, pkg-config }:

dockerTools.buildImage {
  name = "rust-backend";

  copyToRoot = buildEnv {
    name = "rust-backend-root";
    paths = [
      bash
      cargo
      rust-bindgen
      rust-analyzer
      rustc
      nodejs
      meson
      ninja
      pkg-config
    ];
    pathsToLink = [ "/bin" "/etc" "/lib" "/share" ];
  };

  runAsRoot = ''
    mkdir -p /data
  '';

  config = {
    Cmd = [ "/bin/bash" ];
    WorkingDir = "/data";
    Volumes."/data" = { };
  };
}
