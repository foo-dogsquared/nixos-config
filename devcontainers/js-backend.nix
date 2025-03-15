{ dockerTools, foodogsquaredLib, nodejs, bun, pnpm }:

foodogsquaredLib.buildDockerImage {
  name = "js-backend";
  contents = [ nodejs bun pnpm ];
}
