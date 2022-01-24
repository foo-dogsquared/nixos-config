
{ lib, fetchgit, python3, mopidy }:

python3.pkgs.buildPythonApplication rec {
  pname = "mopidy-funkwhale";
  version = "1.0";

  src = fetchgit {
    url = "https://dev.funkwhale.audio/funkwhale/mopidy.git";
    rev = "v${version}";
    sha256 = "sha256-Sr6isp3Eh+XbTXh2zSiB0/UoAShQX6ZWgLQoRMvsung=";
  };

  postPatch = ''
    sed -i 's/vext/pykka/' setup.cfg
  '';

  propagatedBuildInputs = with python3.pkgs; [
    pykka
    requests
    requests_oauthlib
    pygobject3
  ] ++ [ mopidy ];

  checkInputs = with python3.pkgs; [
    pytest
    pytest-cov
    pytest-mock
    requests-mock
    factory_boy
  ];

  meta = with lib; {
    description = "Mopidy extension for streaming music from a Funkwhale server";
    homepage = "https://funkwhale.audio";
    license = licenses.gpl3Plus;
  };
}
