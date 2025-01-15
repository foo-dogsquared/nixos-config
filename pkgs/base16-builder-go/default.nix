{ lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "base16-builder-go";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "tinted-theming";
    repo = pname;
    rev = "v${version}";
    fetchSubmodules = true;
    hash = "sha256-096l9RLmT7es2Y9fLKFLeKAYhkT8FcE5u2RYu3bZIoA=";
  };

  vendorHash = "sha256-fqnGU86L4tEQhujv2opsQs3mQIvp3m2zjfAQ9yfpyOk=";

  meta = with lib; {
    homepage = "https://github.com/tinted-theming/base16-builder-go";
    description = ''
      A Base16 builder written in Go mainly used for convenience on template
      maintainers.
    '';
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = with maintainers; [ foo-dogsquared ];
  };
}
