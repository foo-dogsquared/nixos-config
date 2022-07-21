{ stdenv, lib, fetchFromGitHub, rustPlatform, perl, openssl, pkg-config }:

rustPlatform.buildRustPackage rec {
  pname = "artem";
  version = "1.1.5";

  src = fetchFromGitHub {
    owner = "FineFindus";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-8BP5Flst+rM7T1Jp1dBsZTYOYKm8TyanxYvRH18aXck=";
  };

  cargoSha256 = "sha256-n2NOWrgcMVHpNCHL7r8+Kl1e01XYadaNM7UdE8fQo1U=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ perl openssl ];
  OPENSSL_NO_VENDOR = 1;

  # These all requires network access.
  checkFlags = [
    "--skip url_input"
    "--skip full_file_compare_url"
  ];

  meta = with lib; {
    homepage = "https://github.com/FineFindus/artem";
    description =
      "Command-line application for converting images to ASCII art.";
    license = licenses.mpl20;
  };
}
