{ stdenv, lib, python3Packages, attrs-strict, swh-core, ... }:

with python3Packages;
buildPythonPackage rec {
  pname = "swh-model";
  version = "6.6.3";

  src = fetchPypi {
    inherit version;
    pname = "swh.model";
    sha256 = "sha256-UFZyC2TVkfzk330GCW7vFHdhqqyC+4VkC9S2wNYIXu4=";
  };

  doCheck = false;
  propagatedBuildInputs = [
    click
    dulwich
    deprecated
    typing-extensions
    hypothesis
    iso8601
    python-dateutil
    attrs
    attrs-strict

    swh-core
  ];

  meta = with lib; {
    description = "Software Heritage filesystem";
    homepage = "https://www.softwareheritage.org/";
    license = licenses.gpl3Only;
  };
}
