{ lib
, buildPythonPackage
, fetchFromGitHub
}:

buildPythonPackage rec {
  pname = "blender-machin3tools";
  version = "1.5.0";
  format = "other";

  src = fetchFromGitHub {
    owner = "machin3io";
    repo = "MACHIN3tools";
    rev = "2fd04c54205f3c381b72434609bff6e37ff0bcbb";
    hash = "sha256-vcVEaD4iF7QCRiC653wtj+EvbxKk1QXg11vZJmHJsQw=";
  };

  passthru.blenderPluginName = "MACHIN3tools";

  dontBuild = true;
  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/blender/scripts/addons/${passthru.blenderPluginName}
    cp -r . $out/share/blender/scripts/addons/${passthru.blenderPluginName}

    runHook postInstall
  '';

  meta = with lib; {
    description = "Collection of Blender tools and pie menus";
    homepage = "https://gumroad.com/l/MACHIN3tools";
    # It says GPL somewhere in the license but I have no clue.
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ foo-dogsquared ];
  };
}
