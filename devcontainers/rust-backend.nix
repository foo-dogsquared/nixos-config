{ dockerTools, foodogsquaredLib, rustc, cargo, rust-bindgen, rust-analyzer
, nodejs }:

dockerTools.buildImage {
  name = "fds-rust-backend";

  copyToRoot = foodogsquaredLib.buildFDSEnv {
    name = "fds-rust-backend-root";
    paths = [ cargo rust-bindgen rust-analyzer rustc nodejs ];
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
