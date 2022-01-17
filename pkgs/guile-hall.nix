{ stdenv, lib, guile_3_0, guile-config, fetchFromGitLab, autoreconfHook
, pkg-config, texinfo }:

stdenv.mkDerivation rec {
  pname = "guile-hall";
  version = "0.4.1";

  src = fetchFromGitLab {
    owner = "a-sassmannshausen";
    repo = pname;
    rev = version;
    sha256 = "sha256-TUCN8kW44X6iGbSJURurcz/Tc2eCH1xgmXH1sMOMOXs=";
  };

  nativeBuildInputs = [ pkg-config autoreconfHook texinfo ];
  propagatedBuildInputs = [ guile_3_0 guile-config ];

  meta = with lib; {
    description = "Command-line application for managing Guile projects";
    homepage = "https://gitlab.com/a-sassmannshausen/guile-hall";
    license = licenses.gpl3;
  };
}
