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
  cfgInteractive = config.dream.archetype.interactive;
  inherit (pkgs) system;
in
{
  options.dream.archetype.quick = {
    enable = mkEnableOption "Enable archetype.quick - this machine is a quick setup that should have common (opinionated) programs installed, depending on other archetypes. Basically this archetype is a is a 'distro' of NixOS with sane defaults for everyday use";
  };
  config = mkIf cfg.enable (mkMerge [
    (mkIf cfgGraphical.enable {
      programs.firefox = {
        enable = true;
        policies = self.config.firefox.policies;
      };
      environment.systemPackages = with pkgs; [
        imv
        kitty
        self.packages.${system}.ungoogled-chromium
        self.packages.${system}.telegram-desktop
        self.packages.${system}.gimp
        self.packages.${system}.mpv
        self.packages.${system}.zathura
      ];
    })
    (mkIf cfgInteractive.enable {
      environment.systemPackages = with pkgs; [
        ncdu
        htop-vim
        ranger
        restic
        rclone
        calc
        chafa
      ];
    })
  ]);
}
