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
  cfg = config.dream.archetype.remote;
in
{
  options.dream.archetype.remote = {
    enable = mkEnableOption "Enable archetype.remote - this machine will be remotely logged into";
  };
  config = mkIf cfg.enable {
  };
}
