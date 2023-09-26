{ lib
, buildPythonPackage
, fetchFromGitHub
, imageio
, openimageio
}:

buildPythonPackage rec {
  pname = "blender-blendergis";
  version = "2.2.8";
  format = "other";

  src = fetchFromGitHub {
    owner = "domlysz";
    repo = "BlenderGIS";
    rev = lib.replaceStrings [ "." ] [ "" ] version;
    hash = "sha256-m3fGLUZqkadxvq6vafFObrNfeWap2tj62dhPnyCN8zw=";
  };

  propagatedBuildInputs = [ imageio ];
  buildInputs = [ openimageio ];

  passthru.blenderPluginName = "BlenderGIS";

  dontBuild = true;
  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/blender/scripts/addons/${passthru.blenderPluginName}
    cp -r . $out/share/blender/scripts/addons/${passthru.blenderPluginName}

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/domlysz/BlenderGIS/";
    description = "Blender addons for interacting with geographic data";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ foo-dogsquared ];
    platforms = platforms.all;
  };
}
