{ buildGoModule, lib }:

buildGoModule (finalAttrs: {
  pname = "foodogsquared-extract-website-icon";
  version = "0.1.0";

  src = lib.cleanSource ./.;

  vendorHash = "sha256-DpTh15/7npw07gX7PdC8IbbyEHlhqHl+puaDMsKaRWQ=";

  meta = with lib; {
    description = "Small utility for extracting website icon";
    mainProgram = finalAttrs.pname;
    license = with licenses; [ bsd3 ];
  };
})
