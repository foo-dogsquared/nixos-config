{ dockerTools, foodogsquaredLib, rustc, cargo, rust-bindgen, rust-analyzer
, nodejs }:

foodogsquaredLib.buildDockerImage rec {
  name = "rust-backend";
  tag = name;
  contents = [ cargo rust-bindgen rust-analyzer rustc nodejs ];
}
