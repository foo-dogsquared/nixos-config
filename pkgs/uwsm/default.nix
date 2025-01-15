{ lib, python311Packages, fetchFromGitHub, meson, ninja, pkg-config

# This is for substituting shebangs in its plugins.
, coreutils }:

python311Packages.buildPythonPackage rec {
  pname = "uwsm";
  version = "0.14.0";
  format = "other";

  src = fetchFromGitHub {
    owner = "Vladimir-csp";
    repo = "uwsm";
    rev = "v${version}";
    hash = "sha256-n80FZ6rEguTN9ouEqI+bc5FOSeFQ8ynV+XDL2K/ZIxI=";
  };

  patches = [ ./0001-chore-add-build-backend-for-pyproject.patch ];

  nativeBuildInputs = [ meson ninja pkg-config ];

  propagatedBuildInputs = with python311Packages; [ pyxdg dbus-python ];

  postFixup = ''
    substituteInPlace $out/share/uwsm/plugins/*.sh \
      --replace '/bin/false' '${lib.getExe' coreutils "false"}'
  '';

  meta = with lib; {
    homepage = "https://github.com/Vladimir-csp/uwsm";
    description = "Session manager for standalone Wayland window managers.";
    license = licenses.mit;
    maintainers = with maintainers; [ foo-dogsquared ];
    mainProgram = "uwsm";
    platforms = platforms.linux;
  };
}
