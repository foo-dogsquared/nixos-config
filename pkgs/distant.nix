{ stdenv, lib, rustPlatform, fetchFromGitHub, perl, pkg-config, openssl }:

rustPlatform.buildRustPackage rec {
  version = "0.16.4";
  pname = "distant";

  src = fetchFromGitHub {
    owner = "chipsenkbeil";
    repo = "distant";
    rev = "v${version}";
    sha256 = "sha256-lCiTlyzp+q3NnwrILQZYM60fmbjfWFWYAy1rn7HqP54=";
  };
  cargoSha256 = "sha256-0oCSHstuZ/K+cerOa8xEHett8diVmDTjzvo+uLuRtWo=";

  # We'll just tell to use the system's openssl to build openssl-sys.
  OPENSSL_NO_VENDOR = 1;
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ perl openssl ];

  meta = with lib; {
    description = "Remotely edit files and run programs";
    homepage = "https://github.com/chipsenkbeil/distant";
    license = lib.licenses.mit;
  };
}
