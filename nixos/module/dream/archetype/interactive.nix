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
  cfg = config.dream.archetype.interactive;
in
{
  options.dream.archetype.interactive = {
    enable = mkEnableOption "Enable archetype.interactive";
  };
  config = mkIf cfg.enable {
  };
}
