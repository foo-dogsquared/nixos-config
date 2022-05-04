{ stdenv, lib, fetchFromGitHub, rustPlatform, util-linux }:

rustPlatform.buildRustPackage rec {
  pname = "hush";
  version = "0.1.3-alpha";

  src = fetchFromGitHub {
    owner = "hush-shell";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-7u7vl4kDRA6/ZaouDNZb6CQQsMJoJmPAaoBcnmpenRk";
  };

  checkInputs = [ util-linux ];
  cargoSha256 = "sha256-PGNEqGh0+/U4o84U7H59vxGPqQHYMskUAtNsKS+4xv8=";

  postPatch = ''
    patchShebangs ./src/runtime/tests/data/stdout-stderr.sh
  '';

  meta = with lib; {
    homepage = "https://github.com/hush-shell/hush";
    description = "Unix shell based on the Lua programming language.";
    license = licenses.mit;
    platform = platforms.unix;
  };
}
