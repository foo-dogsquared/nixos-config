{ lib, python3Packages, swh-core, swh-model, swh-auth, ... }:

with python3Packages;
buildPythonPackage rec {
  pname = "swh-web-client";
  version = "0.5.0";

  src = fetchPypi {
    inherit version;
    pname = "swh.web.client";
    sha256 = "sha256-TC3KMMf2lpZA9DuwViu1Osb07eT25K+LyS49jeNZVwA=";
  };

  doCheck = false;
  propagatedBuildInputs = [
    python-dateutil
    click
    requests

    swh-core
    swh-model
    swh-auth
  ];

  meta = with lib; {
    description = "Software Heritage web client";
    homepage = "https://forge.softwareheritage.org/source/swh-web-client/";
    license = licenses.gpl3Only;
  };
}
