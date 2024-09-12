{ lib, fetchFromGitHub, python3, mopidy }:

python3.pkgs.buildPythonApplication rec {
  pname = "mopidy-listenbrainz";
  version = "0.3.0";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "suaviloquence";
    repo = "mopidy-listenbrainz";
    rev = "v${version}";
    hash = "sha256-kYZgG2KQMTxMR8tdwwCKkfexDcxcndXG9LSdlnoN/CY=";
  };

  propagatedBuildInputs = with python3.pkgs;
    [ pykka musicbrainzngs ] ++ [ mopidy ];

  meta = with lib; {
    description =
      "Mopidy extension for getting recommendations with Listenbrainz";
    homepage = "https://github.com/suaviloquence/mopidy-listenbrainz";
    license = licenses.apsl20;
    platforms = mopidy.meta.platforms;
  };
}
