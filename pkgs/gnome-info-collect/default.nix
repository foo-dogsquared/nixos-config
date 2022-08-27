{ lib, fetchFromGitLab, meson, ninja, pkg-config, gobject-introspection, accountsservice, python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "gnome-info-collect";
  version = "1.0-7";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    repo = pname;
    owner = "vstanek";
    rev = "v${version}";
    sha256 = "sha256-9C1pVCOaGLz0xEd2eKuOQRu49GOLD7LnDYvgxpCgtF4=";
  };

  format = "other";

  propagatedBuildInputs = with python3Packages; [
    pygobject3
    requests
  ] ++ [
    gobject-introspection
  ];

  buildInputs = [
    accountsservice
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  meta = with lib; {
    homepage = "https://gitlab.gnome.org/vstanek/gnome-info-collect";
    description = "Utility to collect and send anonymized information for GNOME";
    license = licenses.gpl3Only;
  };
}
