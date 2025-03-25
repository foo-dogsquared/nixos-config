{ stdenv, lib, python3Packages, aiohttp-utils, ... }:

with python3Packages;
buildPythonPackage rec {
  pname = "swh-core";
  version = "4.0.0";
  pyproject = true;

  src = fetchPypi {
    inherit version;
    pname = "swh_core";
    hash = "sha256-da0Kx/pyHybW8oSIyH0/UqivGkSsvnQe7OoVY2p0glA=";
  };

  # Tests require network access.
  doCheck = false;

  propagatedBuildInputs = [
    click
    deprecated
    pyyaml
    python-magic
    sentry-sdk_2

    # swh.core.db
    psycopg2
    typing-extensions

    # swh.core.github
    tenacity
    requests

    # swh.core.api
    aiohttp
    aiohttp-utils
    blinker
    flask
    iso8601
    msgpack
    backports-entry-points-selectable

    setuptools-scm
  ];

  meta = with lib; {
    description = "Software Heritage filesystem";
    homepage = "https://www.softwareheritage.org/";
    license = licenses.gpl3Only;
  };
}
