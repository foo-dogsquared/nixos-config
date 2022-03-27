{ stdenv, lib, guile_3_0, fetchFromGitLab, autoreconfHook, pkg-config, texinfo
}:

stdenv.mkDerivation rec {
  pname = "guile-config";
  version = "0.5.0";

  src = fetchFromGitLab {
    owner = "a-sassmannshausen";
    repo = pname;
    rev = version;
    sha256 = "sha256-8Ma2pzqR8il+8H6WVbYLpKBk2rh3aKBr1mvvzdpCNPc=";
  };

  nativeBuildInputs = [ pkg-config autoreconfHook texinfo ];
  propagatedBuildInputs = [ guile_3_0 ];

  postConfigure = ''
    sed -i '/moddir\s*=/s%=.*%=''${out}/share/guile/site%' Makefile
    sed -i '/godir\s*=/s%=.*%=''${out}/share/guile/ccache%' Makefile
    sed -i '/ccachedir\s*=/s%=.*%=''${out}/share/guile/ccache%' Makefile
  '';

  meta = with lib; {
    description = "Library for a declarative approach for configuration";
    homepage = "https://gitlab.com/a-sassmannshausen/guile-config";
    license = licenses.gpl3Only;
  };
}
