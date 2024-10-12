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
  cfg = config.dream.archetype.headless;
in
{
  options.dream.archetype.headless = {
    enable = mkEnableOption "Enable archetype.headless - this machine will not have physical input/output";
  };
  config = mkIf cfg.enable {
  };
}
