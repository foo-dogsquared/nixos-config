{ stdenv, lib, python3Packages, swh-core, swh-model, swh-web-client, ... }:

with python3Packages;
buildPythonPackage rec {
  pname = "swh-fuse";
  version = "1.0.5";

  src = fetchPypi {
    inherit version;
    pname = "swh.fuse";
    sha256 = "sha256-k1h/J47rTsqsB/oW3bptFmdyD5PUGkL3MxM9BnrR3Eo";
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
