{ dockerTools, foodogsquaredLib, nodejs, bun, pnpm }:

dockerTools.buildImage {
  name = "fds-js-backend";

  copyToRoot = foodogsquaredLib.buildFDSEnv {
    name = "fds-js-backend-root";
    paths = [ nodejs bun pnpm ];
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
