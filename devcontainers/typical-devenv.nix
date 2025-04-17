{ dockerTools, neovim, nushell, foodogsquaredLib, }:

foodogsquaredLib.buildDockerImage rec {
  name = "typical-devenv";
  tag = name;
  contents = foodogsquaredLib.stdenv;
}
