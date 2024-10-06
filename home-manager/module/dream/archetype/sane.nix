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
  cfg = config.dream.archetype.sane;
in {
  options.dream.archetype.sane = {
    enable = mkEnableOption "Enable sane archetype - sane defaults";
  };
  config = mkIf cfg.enable {
    home.preferXdgDirectories = true;
    gtk.gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0";
  };
}
