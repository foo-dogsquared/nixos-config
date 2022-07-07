{ stdenv, lib, fetchFromGitHub, rustPlatform, util-linux }:

rustPlatform.buildRustPackage rec {
  pname = "hush";
  version = "0.1.4-alpha";

  src = fetchFromGitHub {
    owner = "hush-shell";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-35iaJTA9GZLiJ8KerwzG0d5CGYo8yhBkrjPp7pDAJpc=";
  };

  checkInputs = [ util-linux ];
  cargoSha256 = "sha256-PW+T9mu6VGyCRwZSuphQfbsKeX6L2RzCrg5gt+9AeHY=";

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
