{ lib, python3Packages, swh-core, swh-model, swh-auth, ... }:

with python3Packages;
buildPythonPackage rec {
  pname = "swh-web-client";
  version = "0.9.0";
  pyproject = true;

  src = fetchPypi {
    inherit version;
    pname = "swh_web_client";
    hash = "sha256-nBFbWJ7qLGtnxy2iryWfsi4n4XuxVddqBdtzPFtUQ5w=";
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
