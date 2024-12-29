{
  self,
  flake,
  inputs,
  ...
}:
{
  pkgs,
  lib,
  config,
  ...
}:
with builtins;
with lib;
with self.lib;
let
  cfg = config.dream.program.direnv;
in {
  options.dream.program.direnv = {
    # FIXME: add package option
    # FIXME: add integration option, currently hardcoded in ZSH cofig with a check
    enable = mkEnableOption "Enable program.direnv";
  };
  config = mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
