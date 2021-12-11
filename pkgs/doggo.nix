{ stdenv, lib, fetchFromGitHub, buildGoModule, installShellFiles }:

buildGoModule rec {
  pname = "doggo";
  version = "0.4.1";

  subPackages = [ "cmd/doggo" "cmd/api" ];

  src = fetchFromGitHub {
    owner = "mr-karan";
    repo = "doggo";
    rev = "v${version}";
    sha256 = "sha256-TG1pWLf/aB/5clzBYdbZcGZb+64oV9olT5xezUWay/M=";
  };

  ldflags = [ "-X main.buildVersion=v${version}" ];
  nativeBuildInputs = [ installShellFiles ];
  vendorSha256 = "sha256-eyR1LuaMkyQqIaV4GN/7Nr1TkdHr+M3C3z/pyNF0Vo4=";

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
