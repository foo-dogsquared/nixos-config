{ lib,
  fetchFromGitHub,
  maven,
  libwebp,
  vorbis-tools,
}:

maven.buildMavenPackage rec {
  pname = "rotp-fusion";
  version = "2024/06/13/2254";

  src = fetchFromGitHub {
    owner = "Xilmi";
    repo = "Rotp-Fusion";

    # We'll just use URL-encoded strings just to be safe.
    rev = "2024%2F06%2F13%2F2254";
    hash = "sha256-gupeVfIrbFm5B11NdERtnXgkzRMa+yw5vC9MJVeXcys=";
  };

  mvnHash = "";

  nativeBuildInputs = [
    libwebp
    vorbis-tools
  ];

  meta = with lib; {
    description = "Mod of Remnants of the Precursors with more features";
    homepage = "https://github.com/Xilmi/Rotp-Fusion";
    license = with licenses; [
      # For the Java codebase made by Ray Fowler.
      gpl3Only

      # Java Files in `src/rotp/apachemath` folder.
      asl20

      # The Java-rewrite of the following code at:
      #
      # http://hjemmesider.diku.dk/~torbenm/Planet
      {
        free = true;
        url = "http://hjemmesider.diku.dk/~torbenm/Planet";
      }

      # All images made by Peter Penev, audio from Remi Agullo, and
      # various text written by Jeff Colucci and its translations.
      cc-by-nc-nd-40
    ];
    platforms = platforms.linux;
  };
}
