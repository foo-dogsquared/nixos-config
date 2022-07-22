{ stdenv, lib, fetchFromGitHub, buildGoModule, installShellFiles }:

buildGoModule rec {
  pname = "doggo";
  version = "0.5.4";

  subPackages = [ "cmd/doggo" "cmd/api" ];

  src = fetchFromGitHub {
    owner = "mr-karan";
    repo = "doggo";
    rev = "v${version}";
    sha256 = "sha256-6jNs8vigrwKk47Voe42J9QYMTP7KnNAtJ5vFZTUW680=";
  };

  ldflags = [ "-X main.buildVersion=v${version}" ];
  nativeBuildInputs = [ installShellFiles ];
  vendorSha256 = "sha256-pyzu89HDFrMQqYJZC2vdqzOc6PiAbqhaTgYakmN0qj8=";

  postInstall = ''
    # The binary names come from the Makefile only without the '.bin. extension.
    mv $out/bin/{api,doggo-api}

    installShellCompletion completions/doggo.{fish,zsh}
  '';

  meta = with lib; {
    description = "HTTP DNS client for humans";
    homepage = "https://github.com/mr-karan/doggo";
    license = licenses.mit;
  };
}
