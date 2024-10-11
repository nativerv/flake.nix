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
  cfg = config.dream.archetype.graphical;
in
{
  options.dream.archetype.graphical = {
    enable = mkEnableOption "Enable archetype.graphical";
  };
  config = mkIf cfg.enable {
  };
}
