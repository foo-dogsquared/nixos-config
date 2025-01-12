final: prev:

let
  rotpDesktop = prev.makeDesktopItem {
    name = "com.remnantsoftheprecursors.ROTP";
    desktopName = "Remnants of the Precursors";
    exec = "rotp";
    type = "Application";
    icon = "com.remnantsoftheprecursors.ROTP";
    categories = [ "Application" "Game" ];
  };
in
{
  rotp-foodogsquared = prev.rotp.overrideAttrs (finalAttrs: prevAttrs: {
    desktopItems = (prevAttrs.desktopItems or []) ++ [ rotpDesktop ];
    nativeBuildInputs = prevAttrs.nativeBuildInputs or [] ++ [
      prev.copyDesktopItems
    ];
    postInstall = ''
      ${prevAttrs.postInstall or ""}
      install -Dm0644 ${./com.remnantsoftheprecursors.ROTP.png} ${placeholder "out"}/share/icons/hicolor/128x128/apps/com.remnantsoftheprecursors.ROTP.png
    '';
  });
}
