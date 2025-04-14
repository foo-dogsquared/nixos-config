{ lib, rustPlatform, fetchFromGitHub, cmake, pkg-config, openssl }:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fastn";
  version = "0.4.100";

  src = fetchFromGitHub {
    owner = "fastn-stack";
    repo = finalAttrs.pname;
    rev = finalAttrs.version;
    hash = "sha256-4tON3VXFUs8gSRKmWk9eOwuP43DhMzchnve5ZpVpSbg=";
  };

  cargoHash = "sha256-HfzWaE5/j5IGz+n3EsQh8iYhKWZV1d40UKKMy2yY6D4=";
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
