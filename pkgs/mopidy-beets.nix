{ lib, fetchFromGitHub, python3, mopidy }:

python3.pkgs.buildPythonApplication rec {
  pname = "mopidy-beets";
  version = "4.0.1";

  src = fetchFromGitHub {
    owner = "mopidy";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-HvhYAGtgf2rpzIJwMspGtHcrk4IZxPX1jZbNNwQCJA4=";
  };

  propagatedBuildInputs = with python3.pkgs; [
    pykka
    requests
  ] ++ [ mopidy ];

  checkInputs = with python3.pkgs; [
    pytest
    pytest-cov
  ];

  meta = with lib; {
    description = "Mopidy extension for playing music from a Beets collection";
    homepage = "https://github.com/mopidy/mopidy-beets";
    license = licenses.mit;
  };
}
