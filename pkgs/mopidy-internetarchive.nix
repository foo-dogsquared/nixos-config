{ lib, fetchFromGitHub, python3, mopidy }:

python3.pkgs.buildPythonApplication rec {
  pname = "mopidy-internetarchive";
  version = "3.0.1";

  src = fetchFromGitHub {
    owner = "tkem";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-whlJJJR4wgeAIStQRwI44oz0sBqiDAh+F157Y9RUzY0=";
  };

  propagatedBuildInputs = with python3.pkgs;
    [ cachetools pykka requests setuptools uritools ] ++ [ mopidy ];

  checkInputs = with python3.pkgs; [ pytest pytest-cov ];

  meta = with lib; {
    description =
      "Mopidy extension for listening to audio from Internet Archive";
    homepage = "https://github.com/tkem/mopidy-internetarchive";
    license = licenses.asl20;
  };
}
