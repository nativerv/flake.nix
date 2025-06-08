{
  self,
  flake,
  inputs,
  ...
}:
{
  pkgs,
  lib,
  config,
  ...
}:
with builtins;
with lib;
with self.lib;
let
  cfg = config.dream.program.gdb;
in
{
  options.dream.program.gdb = {
    enable = mkEnableOption "Enable program.gdb";
  };
  config = mkIf cfg.enable (mkMerge [
    {
      # XXX: do i want to install gdb here? it's usually installed per project
      #      in it's devshell.
      configFile."gdb/gdbearlyinit".text = ''
        set history save on
        set history size ${toString (1024*1024)}
        set history remove-duplicates 2
        shell mkdir -p "${config.xdg.stateHome}/gdb"
        set history filename ${config.xdg.stateHome}/gdb/history
        set startup-quietly on
        set confirm off
      '';
    }
  ]);
}


