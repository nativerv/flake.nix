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
with self.lib;
with lib;
let
  cfg = config.dream.program.eww;
in {
  options.dream.program.eww = {
    enable = mkEnableOption "Enable eww - widget engine - statusbar & more";
  };
  config = mkIf cfg.enable {
    programs.eww = {
      enable = true;
      configDir = ./eww;
    };
  };
}
