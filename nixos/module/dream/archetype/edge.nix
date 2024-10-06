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
  cfg = config.dream.archetype.edge;
in
{
  options.dream.archetype.edge = {
    enable = mkEnableOption "Enable archetype.edge";
  };
  config = mkIf cfg.enable {
    nix.package = pkgs.nixVersions.git;
  };
}
