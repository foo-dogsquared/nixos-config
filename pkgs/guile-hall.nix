{ stdenv
, lib
, guile_3_0
, guile-config
, fetchFromGitLab
, autoreconfHook
, pkg-config
, texinfo
, makeWrapper
}:

let modules = [ guile-config ];
in stdenv.mkDerivation rec {
  pname = "guile-hall";
  version = "0.4.1";

  src = fetchFromGitLab {
    owner = "a-sassmannshausen";
    repo = pname;
    rev = version;
    sha256 = "sha256-TUCN8kW44X6iGbSJURurcz/Tc2eCH1xgmXH1sMOMOXs=";
  };

  nativeBuildInputs = [ pkg-config autoreconfHook texinfo makeWrapper ];
  propagatedBuildInputs = [ guile_3_0 ];
  buildInputs = modules;

  postConfigure = ''
    sed -i '/moddir\s*=/s%=.*%=''${out}/share/guile/site%' Makefile
    sed -i '/godir\s*=/s%=.*%=''${out}/share/guile/site%' Makefile
    sed -i '/ccachedir\s*=/s%=.*%=''${out}/share/guile/site%' Makefile
  '';

  GUILE_LOAD_PATH =
    let
      guilePath = [ "\${out}/share/guile/site" ] ++ (lib.concatMap
        (module: [
          "${module}/share/guile/site"
          "${module}/share/guile"
          "${module}/share"
        ])
        modules);
    in
    lib.concatStringsSep ":" guilePath;

  GUILE_LOAD_COMPILED_PATH =
    let
      guilePath = [ "\${out}/share/guile/ccache" "\${out}/share/guile/site" ]
        ++ (lib.concatMap
        (module: [
          "${module}/share/guile/ccache"
          "${module}/share/guile/site"
          "${module}/share/guile"
          "${module}/share"
        ])
        modules);
    in
    lib.concatStringsSep ":" guilePath;

  postInstall = ''
    wrapProgram $out/bin/hall \
      --prefix GUILE_LOAD_PATH : "${GUILE_LOAD_PATH}" \
      --prefix GUILE_LOAD_COMPILED_PATH : "${GUILE_LOAD_COMPILED_PATH}"
  '';

  meta = with lib; {
    description = "Command-line application for managing Guile projects";
    homepage = "https://gitlab.com/a-sassmannshausen/guile-hall";
    license = licenses.gpl3Only;
    mainProgram = "hall";
  };
}
