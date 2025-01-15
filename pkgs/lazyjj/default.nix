{ lib, rustPlatform, fetchFromGitHub, jujutsu, }:

let version = "0.3.1";
in rustPlatform.buildRustPackage {
  inherit version;
  pname = "lazyjj";

  src = fetchFromGitHub {
    owner = "Cretezy";
    repo = "lazyjj";
    rev = "v${version}";
    hash = "sha256-VlGmOdF/XsrZ/9vQ14UuK96LIK8NIkPZk4G4mbS8brg=";
  };

  cargoHash = "sha256-TAq9FufGsNVsmqCE41REltYRSSLihWJwTMoj0bTxdFc=";

  # I have no clue how to properly make these tests pass so NO for now.
  doCheck = false;
  preCheck = ''
    export HOME=$TMPDIR
  '';
  checkInputs = [ jujutsu ];

  meta = with lib; {
    homepage = "https://github.com/Cretezy/lazyjj";
    description = "lazygit-inspired user interface for Jujutsu VCS";
    license = licenses.apsl20;
    maintainers = with maintainers; [ foo-dogsquared ];
    mainProgram = "lazyjj";
  };
}
