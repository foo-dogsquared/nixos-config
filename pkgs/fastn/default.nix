{ lib, rustPlatform, fetchFromGitHub, cmake, pkg-config, openssl }:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fastn";
  version = "0.4.99";

  src = fetchFromGitHub {
    owner = "fastn-stack";
    repo = finalAttrs.pname;
    rev = finalAttrs.version;
    hash = "sha256-oomlLE0lha1b9N7CvQKsvlvcLZ8+f5aWjTWqzzgBDUk=";
  };

  cargoHash = "sha256-6WXhxHDqlPJLBgG2VkEQgMV58s6MiAAhQkLQOPBtqpo=";
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
