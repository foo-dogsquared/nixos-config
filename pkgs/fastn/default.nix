{ lib, rustPlatform, fetchFromGitHub, cmake, pkg-config, openssl }:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fastn";
  version = "0.4.101";

  src = fetchFromGitHub {
    owner = "fastn-stack";
    repo = finalAttrs.pname;
    rev = finalAttrs.version;
    hash = "sha256-uuyKmXsvqSEPtglw5DvpRUkiDI6l30F8ZN2Zt1u3h+Y=";
  };

  cargoHash = "sha256-cEFe7in7ezpT+KTJMJ1uW+1lOwgDF3nnWuW7XUN0KtE=";
  cargoBuildFeatures = [ "edition2024" ];
  useFetchCargoVendor = true;

  nativeBuildInputs = [ rustPlatform.bindgenHook cmake pkg-config ];
  buildInputs = [ openssl ];

  checkFlags = [ "--skip=tests::fbt" ];

  meta = with lib; {
    homepage = "https://fastn.com/";
    description = "An integrated development environment for FTD";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ foo-dogsquared ];
    mainProgram = "fastn";
  };
})
