{ stdenv, lib, python3Packages, attrs-strict, swh-core, ... }:

with python3Packages;
buildPythonPackage rec {
  pname = "swh-model";
  version = "6.7.0";

  src = fetchPypi {
    inherit version;
    pname = "swh.model";
    sha256 = "sha256-88xlN/vGXMG858+0A1Wb4EIYC9btRTopY7Ryvw/huDo=";
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
