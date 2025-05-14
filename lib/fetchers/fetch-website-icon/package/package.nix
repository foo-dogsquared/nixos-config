{ buildGoModule, lib, pkg-config, fontconfig }:

buildGoModule (finalAttrs: {
  pname = "foodogsquared-extract-website-icon";
  version = "0.2.0";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ fontconfig ];

  src = lib.cleanSource ./.;

  vendorHash = "sha256-BGxu9fqPZ564d5puazmQm1ed9uXgFb5/Aupb/HYj+Tk=";

  meta = with lib; {
    description = "Small utility for extracting website icon";
    mainProgram = finalAttrs.pname;
    license = with licenses; [ bsd3 ];
  };
})
