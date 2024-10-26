{ dockerTools, buildEnv, nodejs, bun, pnpm }:

dockerTools.buildImage {
  name = "js-backend";

  copyToRoot = buildEnv {
    name = "js-backend-root";
    paths = [ nodejs bun pnpm ];
    pathsToLink = [ "/bin" "/share" "/etc" "/lib" ];
  };

  config.Cmd = [ "/bin/bash" ];
}
