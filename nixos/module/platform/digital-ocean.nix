{ ... }:
{
  modulesPath ? null,
  ...
}:
with builtins;
with lib;
with self.lib;
let
  cfg = config.dream.platform.digital-ocean;
in
{
  imports = optional cfg.enable (modulesPath + "/virtualisation/digital-ocean-config.nix");
  options.dream.platform.digital-ocean = {
    enable = mkEnableOption "Enable platform.digital-ocean";
  };
  config = mkIf cfg.enable {
  };
}
