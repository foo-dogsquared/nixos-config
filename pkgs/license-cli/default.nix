{ stdenv, lib, fetchFromSourcehut, rustPlatform, installShellFiles, scdoc }:

rustPlatform.buildRustPackage rec {
  pname = "license-cli";
  version = "2.6.1";

  src = fetchFromSourcehut {
    owner = "~zethra";
    repo = "license";
    rev = version;
    sha256 = "sha256-39W8Jagj656rivWlNWUr7qNeDQtaBdJYUzwYucZhr5o=";
  };

  cargoSha256 = "sha256-CcG71oaqukbU+PBV+izlYwP3yDUE0d4mVjQV2nWIDyg=";

  nativeBuildInputs = [ installShellFiles ];
  preInstall = ''
    ${scdoc}/bin/scdoc < doc/license.scd > license.1
  '';
  postInstall = ''
    installShellCompletion completions/license.{bash,fish}
    installShellCompletion --zsh completions/_license
    installManPage ./license.1
  '';

  meta = with lib; {
    homepage = "https://git.sr.ht/~zethra/license";
    description = "Command-line tool to easily add license to your project";
    license = licenses.mpl20;
    mainProgram = "license";
  };
}
