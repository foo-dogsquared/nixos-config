{ stdenv, lib, buildGoModule, fetchFromGitHub, brotli, p7zip }:

buildGoModule rec {
  pname = "butler";
  version = "15.21.0";

  src = fetchFromGitHub {
    owner = "itchio";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-vciSmXR3wI3KcnC+Uz36AgI/WUfztA05MJv1InuOjJM=";
  };

  vendorSha256 = "sha256-vdMu4Q/1Ami60JPPrdq5oFPc6TjmL9klZ6W+gBvfkx0=";

  buildInputs = [ brotli p7zip ];

  # The tests requires the package itself to be installed and IDK how to do it.
  doCheck = false;

  meta = with lib; {
    description = "Command-line itch.io helper";
    homepage = "https://github.com/itchio/butler";
    license = licenses.mit;
  };
}
