{ stdenv, lib, python3Packages, attrs-strict, swh-core, ... }:

with python3Packages;
buildPythonPackage rec {
  pname = "swh-model";
  version = "7.1.0";
  pyproject = true;

  src = fetchPypi {
    inherit version;
    pname = "swh_model";
    hash = "sha256-MdyhpKm4UzIFVMhIlAT75OMUmfDcOFZzk/dJIZASwmE=";
  };

  doCheck = false;
  propagatedBuildInputs = [
    deprecated
    typing-extensions
    hypothesis
    iso8601
    python-dateutil
    attrs
    attrs-strict
    aiohttp
    pytz

    swh-core

    # requirements for CLI
    click
    dulwich
  ];

  meta = with lib; {
    description = "Software Heritage filesystem";
    homepage = "https://www.softwareheritage.org/";
    license = licenses.gpl3Only;
  };
}
