# All of the machine-specific overlays.
[
  (self: super:
  {
    rofi = super.rofi.overrideAttrs (oldAttrs: {
      name = "rofi-next";
      src = super.fetchFromGitHub {
        owner = "davatorium";
        repo = "rofi";
        rev = "802a9489e7fbf809890ab6bf39e62664fa4c134f";
        sha256 = "1qjqw7v6qdmc5bxfaq57cb8hf99vr0prp5bn4yzal7r5im855s8f";
      };
    });
  })
]
