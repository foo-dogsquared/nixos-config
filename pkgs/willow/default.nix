{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule {
  pname = "willow";
  version = "unstable-2024-08-15";

  src = fetchFromGitHub {
    owner = "Amolith";
    repo = "willow";
    rev = "af7202f230e42808b705bb9d4ddd04cfa28b401b";
    hash = "sha256-ewXYkx2P2LO6Stg4P4WuVeDLgy2Zh/NYGkMl43DJ+Es=";
  };

  vendorHash = "sha256-KLDoAd/YbQGW1v8bxffJS1PC8fJyEwWT5vT7g0a7rsg=";

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
