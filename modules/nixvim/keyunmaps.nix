{ config, lib, helpers, ... }:

let
  cfg = config.keyunmaps;

  keyunmapOption = { config, lib, ... }: {
    options = {
      key = lib.mkOption {
        type = lib.types.str;
        description = "The key to unmap.";
        example = "<leader>w";
      };

      mode = lib.mkOption {
        type = with lib.types;
          either helpers.keymaps.modeEnum (listOf helpers.keymaps.modeEnum);
        default = "";
        example = [ "n" "i" "v" ];
        description = ''
          One or more several modes as their shortnames. For more details, see
          `:h map-modes`.
        '';
      };

      options = {
        buffer = lib.mkOption {
          type = with lib.types; either ints.unsigned bool;
          default = true;
          example = 4;
          description = ''
            Remove a mapping from the given buffer. When `0` or `true`, use the
            current buffer.
          '';
        };
      };
    };
  };
in
{
  options.keyunmaps = lib.mkOption {
    type = with lib.types; listOf (submodule keyunmapOption);
    default = [ ];
    example = [
      {
        modes = [ "n" "i" ];
        key = "<leader>w";
        options.buffer = true;
      }
    ];
    description = ''
      A list of keymaps to be removed. Take note, this will occur after
      setting the keymap.
    '';
  };

  config = {
    extraConfigLua = lib.optionalString (cfg != [ ]) (lib.mkAfter ''
      -- Set up unmappings {{{
      do
        local __nixvim_unbinds = ${helpers.toLuaObject cfg}
        for i, unmap in ipairs(__nixvim_unbinds) do
          vim.keymap.del(unmap.mode, unmap.key, unmap.options)
        end
      end
      -- }}}
    '');
  };
}
