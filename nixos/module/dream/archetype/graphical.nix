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
    # TODO: dislpay manager (what if i don't want it)? ssh? vnc? rdp?
    enable = mkEnableOption "Enable archetype.graphical - this machine should have graphical login option";
  };
  config = mkIf cfg.enable {
    dream.archetype.interactive.enable = true;
  };
}
