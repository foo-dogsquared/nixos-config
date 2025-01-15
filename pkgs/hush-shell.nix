{ stdenv, lib, fetchFromGitHub, rustPlatform, toybox }:

rustPlatform.buildRustPackage rec {
  pname = "hush";
  version = "unstable-2023-07-18";

  src = fetchFromGitHub {
    owner = "hush-shell";
    repo = pname;
    rev = "01b4303d86048c36c2bc196d8a6fba1bddfa0811";
    hash = "sha256-MH7Qb5FgAvfgfuYihomYDHA456/WU1zf5P9mneB5Og4=";
  };

  cargoHash = "sha256-iN8qOZoTJwvxKQT0Plm0SjwaBUE+vSM0r9FERr4smeo=";

  postPatch = ''
    patchShebangs ./src/runtime/tests/data/stdout-stderr.sh
  '';

  checkInputs = [ toybox ];
  checkFlags =
    [ "--skip=tests::test_token_kind_size" "--skip=tests::test_positive" ];

  meta = with lib; {
    homepage = "https://github.com/hush-shell/hush";
    description = "Unix shell based on the Lua programming language.";
    license = licenses.mit;
    platform = platforms.unix;
  };
}
