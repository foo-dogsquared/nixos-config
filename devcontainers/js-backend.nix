{ dockerTools, foodogsquaredLib, nodejs, bun, pnpm }:

foodogsquaredLib.buildDockerImage rec {
  name = "js-backend";
  tag = name;
  contents = [ nodejs bun pnpm ];
}
