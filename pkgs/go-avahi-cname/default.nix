{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "go-avahi-cname";
  version = "2.0.6";

  src = fetchFromGitHub {
    owner = "grishy";
    repo = "go-avahi-cname";
    rev = "v${version}";
    hash = "sha256-hOX7/9mgWkdm6Rwe5zg0n4WC6y4erilMP5QPEWVSadI=";
  };

  vendorHash = "sha256-EmEnnENKzWUY5djFZlKWNFLkyZ1hzNW+4HF0ui45GjI=";

  meta = with lib; {
    homepage = "https://github.com/grishy/go-avahi-cname";
    license = licenses.mit;
    description = "Lightweight mDNS publisher of subdomains for your machine";
    mainProgram = "go-avahi-cname";
    maintainers = with maintainers; [ foo-dogsquared ];
  };
}
