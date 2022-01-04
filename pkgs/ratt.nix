{ stdenv, lib, fetchFromSourcehut, buildGoModule }:

buildGoModule rec {
  pname = "ratt";
  version = "2022-01-04-a9c98c53";

  src = fetchFromSourcehut {
    owner = "~ghost08";
    repo = pname;
    rev = "a9c98c535e82f5110e7e47c81ffd9c93dde63fb6";
    sha256 = "sha256-7Bu/Hr+HiIswURhvC3fItPQZN3Ca9WwqkZ4rGdaOXdQ=";
  };

  subPackages = [ "cmd/ratt" ];
  vendorSha256 = "sha256-JTlrtI3IS3hyQeHlS1ED7TObNon3bkNp6+CSVdbGD0A=";

  postInstall = ''
    # Move the built-in packaged filters into the appropriate folder.
    install -Dm644 confs/* -t $out/share/${pname}
  '';

  meta = with lib; {
    homepage = "https://git.sr.ht/~ghost08/ratt";
    description = "Make an RSS feed on all the things";
    license = licenses.mit;
  };
}
