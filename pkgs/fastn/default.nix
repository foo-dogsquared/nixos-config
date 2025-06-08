{ lib, rustPlatform, fetchFromGitHub, cmake, pkg-config, openssl }:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fastn";
  version = "0.4.102";

  src = fetchFromGitHub {
    owner = "fastn-stack";
    repo = finalAttrs.pname;
    rev = finalAttrs.version;
    hash = "sha256-+LKAjxvx2zQjBb65HHz28RItoZwOPMqfdxQApT0/SEA=";
  };

  cargoHash = "sha256-zy+AO/Ni+dYWospuxnv6t5I8qXWRIDY6p6+SLJS8EN0=";
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
