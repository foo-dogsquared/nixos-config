{ stdenv
, lib
, fetchurl
, autoreconfHook
, recoll
, python3Packages
, glib
, gobject-introspection
, wrapGAppsHook
, gnome
}:

python3Packages.buildPythonPackage rec {
  pname = "gnome-search-provider-recoll";
  version = "1.1.1";

  src = fetchurl {
    url =
      "https://www.lesbonscomptes.com/recoll/downloads/gssp-recoll-${version}.tar.gz";
    sha256 = "sha256-CSW1EvLXa4SXSak8wMFfBBqtS2LkSGeu4El9fEBN/aY=";
  };

  format = "other";
  strictDeps = false;
  dontWrapGApps = true;
  nativeBuildInputs = [ wrapGAppsHook autoreconfHook gobject-introspection ];
  propagatedBuildInputs = [ recoll ]
    ++ (with python3Packages; [ pydbus pygobject3 ]);
  buildInputs = [ glib ];

  postPatch = ''
    substituteInPlace gssp-recoll.py --replace "/usr/share" "${gnome.gnome-shell}/share"
  '';

  meta = with lib; {
    description = "GNOME search provider for Recoll";
    homepage = "https://www.lesbonscomptes.com/recoll/";
    license = licenses.lgpl21;
    platforms = platforms.linux;
  };
}
