{ stdenv, lib, python3Packages, attrs-strict, swh-core, ... }:

with python3Packages;
buildPythonPackage rec {
  pname = "swh-model";
  version = "6.3.1";

  src = fetchPypi {
    inherit version;
    pname = "swh.model";
    sha256 = "sha256-9bORvIz5hCTZ+MDOY7mLViax7MkKjLq333EtINs+BjI=";
  };

  doCheck = false;
  propagatedBuildInputs = [
    click
    dulwich
    deprecated
    typing-extensions
    hypothesis
    iso8601
    dateutil
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
