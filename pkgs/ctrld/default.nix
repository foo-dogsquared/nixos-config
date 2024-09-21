{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule rec {
  pname = "ctrld";
  version = "1.3.7";

  src = fetchFromGitHub {
    owner = "Control-D-Inc";
    repo = "ctrld";
    rev = "v${version}";
    hash = "sha256-3rAGH3GfCQR+Ii5KazsgQzydeWlPeHpiEvHNHQXjNVQ=";
  };

  vendorHash = "sha256-UN0gOFxMS0iWvg6Iv+aeYoduffJ9Zanz1htRh3ANjkY=";

  # It takes a long time so uhhh...
  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/Control-D-Inc/ctrld";
    description = "Multi-protocol DNS proxy";
    license = licenses.mit;
    mainProgram = "ctrld";
    platforms = platforms.all;
  };
}
