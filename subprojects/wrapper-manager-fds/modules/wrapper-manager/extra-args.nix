{ pkgs, ... }:

{
  _module.args = {
    wrapperManagerLib = import ../../lib { inherit pkgs; };
  };
}
