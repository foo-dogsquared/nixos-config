{ pkgs, lib, self }:

rec {
  /**
    Naively get the absolute path of a `.desktop` file given a derivation and a
    name.

    # Arguments

    drv
    : The derivation.

    name
    : The name of the `.desktop` file (without the `.desktop` extension).

    # Type

    ```
    getXdgDesktop :: Derivation -> String -> Path
    ```

    # Example

    ```nix
    getXdgDesktop pkgs.wezterm "org.wezfurlong.wezterm"
    => /nix/store/$HASH-wezterm-org.wezterm.wezterm.desktop
    ```
  */
  getXdgDesktop = drv: name:
    "${drv}/share/applications/${name}.desktop";

  /**
    Naively get the absolute path of an autostart file given a derivation and a
    name.

    # Arguments

    drv
    : The derivation.

    name
    : The name of the `.desktop` file (without the `.desktop` extension).

    # Type

    ```
    getXdgDesktop :: Derivation -> String -> Path
    ```

    # Example

    ```nix
    getXdgDesktop pkgs.wezterm "org.wezfurlong.wezterm"
    => /nix/store/$HASH-wezterm-org.wezterm.wezterm.desktop
    ```
  */
  getXdgAutostartFile = drv: name:
    "${drv}/etc/xdg/autostart/${name}.desktop";
}
