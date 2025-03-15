{ dockerTools, foodogsquaredLib, rustc, cargo, rust-bindgen, rust-analyzer
, nodejs }:

foodogsquaredLib.buildDockerImage {
  name = "rust-backend";
  contents = [ cargo rust-bindgen rust-analyzer rustc nodejs ];
}
