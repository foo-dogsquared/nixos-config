{ lib, python3Packages, swh-core, swh-model, swh-auth, ... }:

with python3Packages;
buildPythonPackage rec {
  pname = "swh-web-client";
  version = "0.6.0";

  src = fetchPypi {
    inherit version;
    pname = "swh.web.client";
    sha256 = "sha256-o1FcJh3nmGXWZABRQQUj3qgDPaHXwfazaBv8f3LENpk=";
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
