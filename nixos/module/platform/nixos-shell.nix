{
  self ? null,
  inputs ? null,
  ...
}:
{
  config ? null,
  lib ? null,
  ...
}:
with builtins;
with lib;
with self.lib;
let
  cfg = config.dream.platform.nixos-shell;
in
{
  imports = optional cfg.enable inputs.nixos-shell.nixosModules.nixos-shell;
  options.dream.platform.nixos-shell = {
    enable = mkEnableOption "Enable platform.nixos-shell";
  };
  config = mkIf cfg.enable {
    nixos-shell.mounts = {
      mountHome = false;
      mountNixProfile = false;
      cache = "none"; # default is "loose"
    };
  };
}
