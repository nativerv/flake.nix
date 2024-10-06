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
  cfg = config.dream.program.ranger;
in
{
  options.dream.program.ranger = {
    enable = mkEnableOption "Enable ranger file manager & config";
  };
  config = mkIf cfg.enable {
    programs.ranger = {
      enable = true;
      settings = {
        preview_images = true;
        preview_images_method = "kitty";
      };
    };
  };
}
