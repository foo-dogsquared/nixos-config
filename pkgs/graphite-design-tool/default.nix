{ rustPlatform, cargo-tauri_1, fetchFromGitHub, wrapGAppsHook, wasm-bindgen-cli, pkg-config, lib }:

rustPlatform.buildRustPackage rec {
  pname = "graphite-design-tool";
  version = "unstable-2024-12-07";

  src = fetchFromGitHub {
    owner = "GraphiteEditor";
    repo = "graphite";
    rev = "b21b1cbfc7cb808ec5e2c66b090660506f07833f";
    hash = "sha256-RJYzS7TUViszDXomShw2h6DOVrER/VkW7cP69aEOQ/k=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-+p9bpj+cSd0Bkpg+e4lwo4C7XqxZBc0McYYsNxAqzaA=";

  nativeBuildInputs = [ cargo-tauri_1 pkg-config wrapGAppsHook wasm-bindgen-cli ];

  meta = with lib; {
    homepage = "https://graphite.rs/";
    description = "2D vector & raster editor that melds traditional layers & tools with a modern node-based, non-destructive, procedural workflow";
    license = licenses.asl20;
    maintainers = with maintainers; [ foo-dogsquared ];
    mainProgram = "graphite";
  };
}
