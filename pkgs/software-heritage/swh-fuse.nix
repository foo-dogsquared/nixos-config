{ stdenv, lib, python3Packages, swh-core, swh-model, swh-web-client, ... }:

with python3Packages;
buildPythonPackage rec {
  pname = "swh-fuse";
  version = "1.1.0";
  pyproject = true;

  src = fetchPypi {
    inherit version;
    pname = "swh.fuse";
    hash = "sha256-pkTZiUm+Sun+7gBNWXJUHUXTmEIz5tjvfGcU4cUL9Xg=";
  };

  doCheck = false;
  propagatedBuildInputs = [
    pyyaml
    aiosqlite
    psutil
    pyfuse3
    python-daemon
    requests

    setuptools-scm

    swh-core
    swh-web-client
    swh-model
  ];

  meta = with lib; {
    description = "Software Heritage filesystem";
    homepage = "https://www.softwareheritage.org/";
    license = licenses.gpl3Only;
  };
}
