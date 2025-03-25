{ stdenv, lib, python3Packages, swh-core, ... }:

with python3Packages;

buildPythonPackage rec {
  pname = "swh-auth";
  version = "0.10.0";
  pyproject = true;

  src = fetchPypi {
    inherit version;
    pname = "swh_auth";
    hash = "sha256-J/5oFm0QSPNeEDKIYHEzSXWA/6uSOj9eu3LXYUTZjC0=";
  };

  # Tests require network access.
  doCheck = false;

  propagatedBuildInputs = [
    click
    pyyaml
    python-keycloak

    # Requirements for Django
    django
    djangorestframework
    sentry-sdk_2

    # Requirements for Starlette
    starlette
    httpx
    aiocache

    swh-core
  ];

  meta = with lib; {
    homepage = "https://forge.softwareheritage.org/source/swh-auth/";
    description = "Authentication utilities for Software Heritage";
    license = licenses.gpl3Only;
  };
}
