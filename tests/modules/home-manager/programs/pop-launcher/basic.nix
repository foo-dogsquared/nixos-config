{ pkgs, ... }:

{
  programs.pop-launcher = {
    enable = true;
    plugins = with pkgs; [
      pop-launcher-plugin-duckduckgo-bangs
      pop-launcher-plugin-brightness
    ];
  };

  test.stubs = {
    pop-launcher = { };
    pop-launcher-plugin-duckduckgo-bangs = {
      outPath = null;
      buildScript = ''
        mkdir -p $out/share/pop-launcher/{scripts,plugins/bangs}
        echo "hello" | tee "$out/share/pop-launcher/plugins/bangs/bangs"
        echo "WHOA" | tee "$out/share/pop-launcher/scripts/whoa"
      '';
    };
    pop-launcher-plugin-brightness = {
      outPath = null;
      buildScript = ''
        mkdir -p "$out/share/pop-launcher/plugins/brightness"
        echo "world" | tee "$out/share/pop-launcher/plugins/brightness/brightness"
      '';
    };
  };

  nmt.script = ''
    assertFileExists home-files/.local/share/pop-launcher/plugins/bangs/bangs
    assertFileExists home-files/.local/share/pop-launcher/scripts/whoa
    assertFileExists home-files/.local/share/pop-launcher/plugins/brightness/brightness
  '';
}
