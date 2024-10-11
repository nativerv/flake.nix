{
  self ? null,
  ...
}:
{
  config ? null,
  lib ? null,
  pkgs ? null,
  ...
}:
with builtins;
with lib;
with self.lib;
let
  cfg = config.dream.archetype.quick;
  cfgGraphical = config.dream.archetype.graphical;
in
{
  options.dream.archetype.quick = {
    enable = mkEnableOption "Enable archetype.quick - quick setup that pulls wanted stuff globally depending on other archetypes";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; mkIf cfgGraphical.enable [
      imv
      kitty
      self.packages.${system}.firefox
      self.packages.${system}.telegram-desktop
      self.packages.${system}.gimp
      self.packages.${system}.mpv
      self.packages.${system}.zathura
    ];
  };
}
