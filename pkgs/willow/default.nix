{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule {
  pname = "willow";
  version = "unstable-2024-05-17";

  src = fetchFromGitHub {
    owner = "Amolith";
    repo = "willow";
    rev = "5219377958faf103e16f16c29b2eb82f33a4f1c4";
    hash = "sha256-MGz+X8Az2Cqzp5SB7L/RU18m15WOIS8vnAjCJwcTQ/s=";
  };

  vendorHash = "sha256-DCqD9GTszw7KJ+BlEX4T1Mra/D7uAFcWsMXg73V8a7k=";

  meta = with lib; {
    homepage = "https://github.com/Amolith/willow";
    description = "Forge-agnostic release tracker";
    license = with licenses; [
      mit
      asl20
    ];
    maintainers = with maintainers; [ foo-dogsquared ];
    mainProgram = "willow";
    platforms = platforms.unix;
  };

}
