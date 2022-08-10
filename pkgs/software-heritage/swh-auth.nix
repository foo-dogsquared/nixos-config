{ stdenv, lib, python3Packages, swh-core, ... }:

with python3Packages;
buildPythonPackage rec {
  pname = "swh-auth";
  version = "0.6.6";

  src = fetchPypi {
    inherit version;
    pname = "swh.auth";
    sha256 = "sha256-TWLrZC4Iv0HTCtGjraPZRpGLiZFxTXZw6trWzC0GkHw=";
  };

  # Tests require network access.
  doCheck = false;

  propagatedBuildInputs = [
    django
    djangorestframework
    sentry-sdk
    click
    pyyaml
    python-keycloak

    swh-core
  ];

  meta = with lib; {
    homepage = "https://forge.softwareheritage.org/source/swh-auth/";
    description = "Authentication utilities for Software Heritage";
    license = licenses.gpl3Only;
  };
}
