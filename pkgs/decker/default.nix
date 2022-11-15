{ stdenv
, lib
, fetchFromGitHub
, SDL2
, SDL2_image
, unixtools
, multimarkdown
}:

stdenv.mkDerivation rec {
  pname = "decker";
  version = "1.2";

  src = fetchFromGitHub {
    owner = "JohnEarnest";
    repo = "Decker";
    rev = "v${version}";
    sha256 = "sha256-cHml24dDSe7dJH2N8KQ2/ekCNk3Cl+eNHeC6ic5kSg4=";
  };

  buildInputs = [
    SDL2
    SDL2_image
    multimarkdown
    unixtools.xxd
  ];

  buildPhase = ''
    make lilt
    make decker
    make docs
  '';

  installPhase = ''
    runHook preInstall

    install -Dm0755 ./c/build/lilt -t $out/bin
    install -Dm0755 ./c/build/decker -t $out/bin
    install -Dm0644 ./syntax/vim/ftdetect/lil.vim -t $out/etc/xdg/vim/ftdetect
    install -Dm0644 ./syntax/vim/syntax/lil.vim -t $out/etc/xdg/vim/syntax
    install -Dm0644 ./examples/decks/*.deck -t $out/share/decker/examples/decks
    install -Dm0644 ./examples/lilt/*.lil -t $out/share/decker/examples/lilt

    mkdir -p $out/share/doc
    cp -r ./docs/* $out/share/doc

    runHook postInstall
  '';

  postPatch = ''
    patchShebangs ./scripts/*
    substituteInPlace ./scripts/install.sh --replace "sudo " ""
  '';

  meta = with lib; {
    homepage = "https://beyondloom.com/decker/index.html";
    description = "Multimedia platform for creating and sharing interactive documents";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
